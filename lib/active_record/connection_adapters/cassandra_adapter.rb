require 'active_record/base'
require 'active_record/connection_adapters/abstract_adapter'
require 'cassandra'
require 'active_cassandra/cf'
require 'active_cassandra/sqlparser.tab'

module ActiveRecord
  class Base
    def self.cassandra_connection(config)
      config.symbolize_keys!
      host = config[:host] || '127.0.0.1'
      port = config[:port] || 9160

      unless (keyspace = config[:keyspace] || config[:database])
        raise ArgumentError, "No database file specified. Missing argument: keyspace"
      end

      thrift_client_options = config.dup
      [:adapter, :host, :port, :keyspace, :database].each {|i| thrift_client_options.delete(i) }

      client = Cassandra.new(keyspace, "#{host}:#{port}", thrift_client_options)
      ConnectionAdapters::CassandraAdapter.new(client, logger, config)
    end
  end # class Base

  module ConnectionAdapters
    class CassandraAdapter < AbstractAdapter
      def initialize(client, logger, config)
        super(client, logger)
        @config = config
      end

      def supports_count_distinct?
        false
      end

      def select(sql, name = nil)
        log(sql, name)

        parsed_sql = ActiveCassandra::SQLParser.new(sql).parse

        cf = parsed_sql[:table].to_sym
        cond = parsed_sql[:condition]
        count = parsed_sql[:count]
        # not implemented:
        # distinct = parsed_sql[:distinct]
        sqlopts, casopts = rowopts(parsed_sql)

        if count and cond.empty? and sqlopts.empty?
          [{count => @connection.count_range(cf, casopts)}]
        elsif is_id?(cond)
          ks = [cond].flatten
          @connection.multi_get(cf, ks, casopts).values
        else
          rows = @connection.get_range(cf, casopts).select {|i| i.columns.length > 0 }.map do |key_slice|
            key_slice_to_hash(key_slice)
          end

          unless cond.empty?
            rows = filter(cond).call(rows)
          end

          if (offset = sqlopts[:offset])
            rows = rows.slice(offset..-1)
          end

          if (limit = sqlopts[:limit])
            rows = rows.slice(0, limit)
          end

          count ? [{count => rows.length}] : rows
        end
      end

      def insert_sql(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
        log(sql, name)

        parsed_sql = ActiveCassandra::SQLParser.new(sql).parse
        table = parsed_sql[:table]
        cf = table.to_sym
        column_list = parsed_sql[:column_list]
        value_list = parsed_sql[:value_list]

        class_name = ActiveRecord::Base.class_name(table)
        rowid = Module.const_get(class_name).__identify.to_s

        nvs = {}
        column_list.zip(value_list).each {|n, v| nvs[n] = v.to_s }

        @connection.insert(cf, rowid, nvs)

        return rowid
      end

      def update_sql(sql, name = nil)
        log(sql, name)
        parsed_sql = ActiveCassandra::SQLParser.new(sql).parse
        cf = parsed_sql[:table].to_sym
        cond = parsed_sql[:condition]

        nvs = {}
        parsed_sql[:set_clause_list].each do |n, v|
          n = n.split('.').last
          nvs[n] = v.to_s
        end

        n = 0

        if is_id?(cond)
          ks = [cond].flatten
          rs = @connection.multi_get(cf, ks)

          ks.each do |key|
            row = rs[key]
            @connection.insert(cf, key, row.merge(nvs))
            n += 1
          end
        else
          rows = @connection.get_range(cf).select {|i| i.columns.length > 0 }.map do |key_slice|
            key_slice_to_hash(key_slice)
          end

          unless cond.empty?
            rows = filter(cond).call(rows)
          end

          rows.each do |row|
            @connection.insert(cf, row['id'], row.merge(nvs))
            n += 1
          end
        end

        return n
      end

      def delete_sql(sql, name = nil)
        log(sql, name)

        parsed_sql = ActiveCassandra::SQLParser.new(sql).parse
        cf = parsed_sql[:table].to_sym
        cond = parsed_sql[:condition]

        n = 0

        if is_id?(cond)
          [cond].flatten.each do |key|
            @connection.remove(cf, key)
            n += 1
          end
        else
          rows = @connection.get_range(cf).select {|i| i.columns.length > 0 }

          unless cond.empty?
            rows = rows.map {|i| key_slice_to_hash(i) }
            rows = filter(cond).call(rows)

            rows.each do |row|
              @connection.remove(cf, row['id'])
              n += 1
            end
          else
            rows.each do |key_slice|
              @connection.remove(cf, key_slice.key)
              n += 1
            end
          end
        end

        return n
      end

      def add_limit_offset!(sql, options)
        if (limit = options[:limit])
          if limit.kind_of?(Numeric)
            sql << " LIMIT #{limit.to_i}"
          else
            sql << " LIMIT #{quote(limit)}"
          end
        end

        if (offset = options[:offset])
          if offset.kind_of?(Numeric)
            sql << " OFFSET #{offset.to_i}"
          else
            sql << " OFFSET #{quote(offset)}"
          end
        end
      end

      private
      def key_slice_to_hash(key_slice)
        hash = {'id' => key_slice.key}

        key_slice.columns.each do |i|
          column = i.column
          hash[column.name] = column.value
        end

        return hash
      end

      def is_id?(cond)
        not cond.kind_of?(Array) or not cond.all? {|i| i.kind_of?(Hash) }
      end

      def filter(cond)
        fs = []

        cond.each do |c|
          name, op, expr, has_not = c.values_at(:name, :op, :expr, :not)
          name = name.split('.').last
          expr = Regexp.compile(expr) if op == '$regexp'

          func = case op
                 when '$in'
                   lambda {|i| expr.include?(i) }
                 when '$bt'
                   lambda {|i| expr[0] <= i and i <= expr[1] }
                 when '$regexp'
                   lambda {|i| i =~ Regexp.compile(expr) }
                 when :'>=', :'<=', :'>', :'<'
                   lambda {|i| i.to_i.send(op, expr.to_i) }
                 else
                   lambda {|i| i.send(op, expr) }
                 end

          fs << (has_not ? lambda {|row| not func.call(row[name]) } : lambda {|row| func.call(row[name])})
        end

        lambda do |rows|
          fs.inject(rows) {|r, f| r.select {|i| f.call(i) } }
        end
      end

      def rowopts(parsed_sql)
        order, limit, offset = parsed_sql.values_at(:order, :limit, :offset)
        sqlopts = {}
        casopts = {}

        # not implemented:
        # if order
        #   name, type = order.values_at(:name, :type)
        #   ...
        # end

        if offset
          if offset.kind_of?(Numeric)
            sqlopts[:offset] = offset
          else
            # XXX: offset is not equals to SQL OFFSET
            casopts[:start] = offset
          end
        end

        if limit
          if limit.kind_of?(Numeric)
            sqlopts[:limit] = limit
          else
            # XXX: limit is not equals to SQL LIMIT
            casopts[:finish] = limit
          end
        end

        return [sqlopts, casopts]
      end

    end # class CassandraAdapter
  end # module ConnectionAdapters
end # module ActiveRecord
