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
      SELF_KEY = '$'
      RELATION_CF_PREFIX = '_relation'
      INDEX_CF_PREFIX = '_index'

      def initialize(client, logger, config)
        super(client, logger)
        @config = config
      end

      def columns(table_name, name = nil)
        class_name = ActiveRecord::Base.class_name(table_name)
        Module.const_get(class_name).columns
      end

      def supports_count_distinct?
        false
      end

      def adapter_name
        "cassandra"
      end

      def tables
        []
      end

      def table_exists?(table)
        true
      end

      def primary_key(table)
      end

      def select(sql, name = nil)
        log(sql, name) do
          parsed_sql = ActiveCassandra::SQLParser.new(sql).parse

          cf = parsed_sql[:table].to_sym
          cond = parsed_sql[:condition]
          count = parsed_sql[:count]
          # XXX: not implemented
          # distinct = parsed_sql[:distinct]
          sqlopts, casopts = rowopts(parsed_sql)

          if count and cond.empty? and sqlopts.empty?
            [{count => @connection.count_range(cf, casopts)}]
          elsif is_id?(cond)
            ks = [cond].flatten
            rs = @connection.multi_get(cf, ks, SELF_KEY, casopts)
            rows = []

            ks.each do |k|
              row = rs[k]
              next if row.empty?
              row['id'] = k
              rows << row
            end

            rows
          else
            rows = select_with_condition(cf, cond, casopts)

            if (offset = sqlopts[:offset])
              rows = rows.slice(offset..-1)
            end

            if (limit = sqlopts[:limit])
              rows = rows.slice(0, limit)
            end

            count ? [{count => rows.length}] : rows
          end
        end # log
      end

      def insert_sql(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
        # XXX: unique check

        log(sql, name) do
          parsed_sql = ActiveCassandra::SQLParser.new(sql).parse
          table = parsed_sql[:table]
          cf = table.to_sym
          column_list = parsed_sql[:column_list]
          value_list = parsed_sql[:value_list]

          class_name = ActiveRecord::Base.class_name(table)
          rowid = Module.const_get(class_name).__identify.to_s

          nvs = {}
          column_list.zip(value_list).each {|n, v| nvs[n] = v.to_s }

          # XXX: insert with relation info
          @connection.insert(cf, rowid, {SELF_KEY => nvs})

          rowid
        end # log
      end

      def update_sql(sql, name = nil)
        log(sql, name) do
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

            ks.each do |key|
              @connection.insert(cf, key, {SELF_KEY => nvs})
              n += 1
            end
          else
            select_with_condition(cf, cond, :key_only => true) do |k|
              @connection.insert(cf, k, {SELF_KEY => nvs})
              n += 1
            end
          end

          n
        end # log
      end

      def delete_sql(sql, name = nil)
        log(sql, name) do
          parsed_sql = ActiveCassandra::SQLParser.new(sql).parse
          cf = parsed_sql[:table].to_sym
          cond = parsed_sql[:condition]

          n = 0

          if is_id?(cond)
            [cond].flatten.each do |key|
              @connection.remove(cf, key)
              n += 1
            end
          else # is_id?(cond)
            select_with_condition(cf, cond, :key_only => true) do |k|
              @connection.remove(cf, k)
              n += 1
            end
          end # is_id?(cond)

          n
        end # log
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

      def __has_many_ids(parent, child_table)
        parent_table = parent.class.table_name
        @connection.get(parent_table.to_sym, parent.id, child_table.to_s).values
      end

      def __associate_from_cassandra(parent, child)
        return false if (parent.blank? or child.blank?)

        relation = (parent.class.__relations || {})[child.class.table_name.to_sym]
        return false unless relation

        __associate_from_cassandra_without_cascade(parent, child, relation)

        if relation[:cascade] == :rdb
          relation_cf = "#{RELATION_CF_PREFIX}_#{child.class.table_name}".to_sym
          identity = relation[:cascade_identifier] ?  relation[:cascade_identifier].call : parent.id
          @connection.insert(relation_cf, child.id.to_s, {parent.class.table_name => {identity => parent.id}})
        elsif relation[:cascade]
          __associate_from_cassandra_without_cascade(child, parent, relation)
        end

        return true
      end

      def __unassociate_from_cassandra(parent, child)
        return false if (parent.blank? or child.blank?)

        relation = (parent.class.__relations || {})[child.class.table_name.to_sym]
        return false unless relation

        __unassociate_from_cassandra_without_cascade(parent, child, relation)

        if relation[:cascade] == :rdb
          relation_cf = "#{RELATION_CF_PREFIX}_#{child.class.table_name}".to_sym
          @connection.remove(relation_cf, child.id.to_s, parent.class.table_name, parent.id)
        elsif relation[:cascade]
          __unassociate_from_cassandra_without_cascade(child, parent, relation)
        end

        return true
      end

      def __rdb_to_cassandra_ids(parent, child_table)
        relation_cf = "#{RELATION_CF_PREFIX}_#{parent.class.table_name}".to_sym
        @connection.get(relation_cf, parent.id.to_s, child_table.to_s).values
      end

      def __associate_from_rdb(parent, child)
        return false if (parent.blank? or child.blank?)

        relation = (parent.class.__relations || {})[child.class.table_name.to_sym]
        return false unless relation

        relation_cf = "#{RELATION_CF_PREFIX}_#{parent.class.table_name}".to_sym
        identity = relation[:identifier] ?  relation[:identifier].call : child.id
        @connection.insert(relation_cf, parent.id.to_s, {child.class.table_name => {identity => child.id}})

        if relation[:cascade]
          child.send("#{parent.class.name.downcase}_id=", parent.id)
          child.save!
        end

        return true
      end

      def __unassociate_from_rdb(parent, child)
        return false if (parent.blank? or child.blank?)

        relation = (parent.class.__relations || {})[child.class.table_name.to_sym]
        return false unless relation

        relation_cf = "#{RELATION_CF_PREFIX}_#{parent.class.table_name}".to_sym
        identity = relation[:identifier] ?  relation[:identifier].call : child.id
        @connection.remove(relation_cf, parent.id.to_s, child.class.table_name, child.id)

        if relation[:cascade]
          child.send("#{parent.class.name.downcase}_id=", nil)
          child.save!
        end

        return true
      end

      private #######################################################

      def __associate_from_cassandra_without_cascade(parent, child, relation)
        identity = relation[:identifier] ?  relation[:identifier].call : child.id.to_s
        @connection.insert(parent.class.table_name.to_sym, parent.id.to_s, {child.class.table_name => {identity => child.id.to_s}})
      end

      def __unassociate_from_cassandra_without_cascade(parent, child, relation)
        @connection.remove(parent.class.table_name.to_sym, parent.id.to_s, child.class.table_name, child.id.to_s)
      end

      def select_with_condition(cf, cond, casopts = {})
        key_only = casopts.delete(:key_only)
        rs = @connection.get_range(cf, casopts)
        selector = filter(cond)

        if key_only
          if block_given?
            if cond.empty?
              rs.each {|key_slice|
                next if key_slice.columns.length.zero?
                row = key_slice.key
                yield(row)
              }
            else
              rs.each {|key_slice|
                next if key_slice.columns.length.zero?
                row = key_slice_to_hash(key_slice)
                yield(row['id']) if selector.call(row)
              }
            end
          else # if block_given?
            rows = []

            if cond.empty?
              rs.each {|key_slice|
                next if key_slice.columns.length.zero?
                row = key_slice.key
                rows << row
              }
            else
              rs.each {|key_slice|
                next if key_slice.columns.length.zero?
                row = key_slice_to_hash(key_slice)
                rows << row['id'] if selector.call(row)
              }
            end

            return rows
          end # if block_given?
        else # if key_only
          if block_given?
            if cond.empty?
              rs.each {|key_slice|
                next if key_slice.columns.length.zero?
                row = key_slice_to_hash(key_slice)
                yield(row)
              }
            else
              rs.each {|key_slice|
                next if key_slice.columns.length.zero?
                row = key_slice_to_hash(key_slice)
                yield(row) if selector.call(row)
              }
            end
          else # if block_given?
            rows = []

            if cond.empty?
              rs.each {|key_slice|
                next if key_slice.columns.length.zero?
                row = key_slice_to_hash(key_slice)
                rows << row
              }
            else
              rs.each {|key_slice|
                next if key_slice.columns.length.zero?
                row = key_slice_to_hash(key_slice)
                rows << row if selector.call(row)
              }
            end

            return rows
          end # if block_given?
        end # if key_only
      end

      def key_slice_to_hash(key_slice)
        hash = {'id' => key_slice.key}
        super_column = nil

        key_slice.columns.each do |column|
          super_column = column.super_column
          break if super_column.name == SELF_KEY
        end

        super_column.columns.each do |column|
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
                   lambda {|i| expr[0].to_i <= i and i <= expr[1].to_i }
                 when '$regexp'
                   lambda {|i| i.to_s =~ Regexp.compile(expr) }
                 when :'>=', :'<=', :'>', :'<'
                   lambda {|i| i.to_i.send(op, expr.to_i) }
                 else
                   lambda {|i| i.send(op, expr.to_s) }
                 end

          fs << (has_not ? lambda {|row| not func.call(row[name]) } : lambda {|row| func.call(row[name])})
        end

        lambda do |row|
          fs.all? {|f| f.call(row) }
        end
      end

      def rowopts(parsed_sql)
        order, limit, offset = parsed_sql.values_at(:order, :limit, :offset)
        sqlopts = {}
        casopts = {}

        # XXX: not implemented
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
