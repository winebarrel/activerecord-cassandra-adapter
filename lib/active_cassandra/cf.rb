require 'active_support'

module ActiveCassandra
  module CF
    def self.included(mod)
      {
        :string    => :to_s,
        :int       => :to_i,
        :float     => :to_f,
        :datetime  => :to_time,
        :timestamp => :to_time,
      }.each do |type, conv|
        mod.instance_eval %{
          def #{type}(name)
            unless @columns
              primary_key = ActiveRecord::ConnectionAdapters::Column.new('id', nil, 'string')
              primary_key.primary = true
              @columns = [primary_key]
            end

            @columns << ActiveRecord::ConnectionAdapters::Column.new(name.to_s, nil, '#{type}')
            class_eval "def \#{name}; v = self[:\#{name}]; (v.nil? || v.blank?) ? nil : v.#{conv}; end"
          end
        }
      end

      mod.instance_eval %{
        def identifier(value)
          unless value.kind_of?(Proc) and value.arity <= 0 
            raise ArgumentError, "Incorrect identifier: \#{value}"
          end

          @__identifier = value
        end

        def __identify
          if @__identifier
            @__identifier.call
          else
            SimpleUUID::UUID.new.to_guid
          end
        end

        def cassandra_client
          client = self.connection.raw_connection
          block_given? ? yield(client) : client
        end

        def associate(table, options = {})
          @__relations ||= {}
          @__relations[table.to_sym] = options

          class_eval <<-EOS
            def \#{table}
              class_name = ActiveRecord::Base.class_name('\#{table}')
              klass = Module.const_get(class_name)
              ids = self.connection.__has_many_ids(self, '\#{table}')
              ids.blank? ? [] : klass.all(:conditions => {:id => ids})
            end

            def add_\#{table.to_s.singularize}(child)
              self.connection.__associate_from_cassandra(self, child)
            end

            def remove_\#{table.to_s.singularize}(child)
              self.connection.__unassociate_from_cassandra(self, child)
            end
          EOS
        end

        def __relations
          @__relations
        end
      }
    end
  end
end
