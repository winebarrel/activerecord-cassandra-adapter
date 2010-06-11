require 'active_support'

module ActiveCassandra
  module Table
    def self.included(mod)
      mod.instance_eval %{
        def associate(table, options = {})
          @__relations ||= {}
          @__relations[table.to_sym] = options

          class_eval <<-EOS
            def \#{table}
              class_name = ActiveRecord::Base.class_name('\#{table}')
              klass = Module.const_get(class_name)
              ids = klass.connection.__rdb_to_cassandra_ids(self, '\#{table}')
              ids.blank? ? [] : klass.all(:conditions => {:id => ids})
            end

            def add_\#{table.to_s.singularize}(child)
              class_name = ActiveRecord::Base.class_name('\#{table}')
              klass = Module.const_get(class_name)
              klass.connection.__associate_from_rdb(self, child)
            end

            def remove_\#{table.to_s.singularize}(child)
              class_name = ActiveRecord::Base.class_name('\#{table}')
              klass = Module.const_get(class_name)
              klass.connection.__unassociate_from_rdb(self, child)
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
