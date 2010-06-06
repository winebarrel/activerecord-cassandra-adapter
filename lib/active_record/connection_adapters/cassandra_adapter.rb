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
        options = {} # XXX:

        if count # XXX:
          [{count => @connection.count_range(cf, options)}]
        elsif is_id?(cond)
          ks = [cond].flatten
          @connection.multi_get(cf, ks, options).values
        else
          @connection.get_range(cf, options).map do |key_slice|
            key_slice_to_hash(key_slice)
          end
        end
      end

      def insert_sql(sql, name = nil, pk = nil, id_value = nil, sequence_name = nil)
        log(sql, name)

        parsed_sql = ActiveCassandra::SQLParser.new(sql).parse
        cf = parsed_sql.values_at[:table].to_sym
        column_list = parsed_sql[:column_list]
        value_list = parsed_sql[:value_list]

        guid = SimpleUUID::UUID.new.to_guid

        nvs = {}
        column_list.zip(value_list).each {|n, v| nvs[n] = v.to_s }

        @connection.insert(cf, guid, nvs)

        return guid
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

        if is_id?(cond)
          ks = [cond].flatten
          rs = @connection.multi_get(cf, ks)

          ks.each do |key|
            row = rs[key]
            @connection.insert(cf, key, row.merge(nvs))
          end
        else
          raise 'not implemented'
          #@connection.get_range(cf, options).each do |key_slice|
          #  row = key_slice_to_hash(key_slice)
          #  @connection.insert(cf, key_slice.key, row.merge(nvs))
          #end
        end

        # XXX:
        1
      end

      def delete_sql(sql, name = nil)
        log(sql, name)

        parsed_sql = ActiveCassandra::SQLParser.new(sql).parse
        cf = parsed_sql[:table].to_sym
        cond = parsed_sql[:condition]

        if is_id?(cond)
          [cond].flatten.each do |key|
            @connection.remove(cf, key)
          end
        else
          raise 'not implemented'
          #@connection.get_range(cf, options).each do |key_slice|
          #  @connection.remove(cf, key_slice.key)
          #end
        end

        # XXX:
        1
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
    end # class CassandraAdapter
  end # module ConnectionAdapters
end # module ActiveRecord
