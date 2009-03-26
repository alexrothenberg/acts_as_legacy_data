module ActiveRecord #:nodoc:
  module Acts #:nodoc:
    module SomebodyElsesData #:nodoc:
      ENVIRONMENTS_TO_STUB_TABLES = [:test, :development]
      
      def self.included(base)
        base.extend(ClassMethods)
      end
      
      module ClassMethods
        def acts_as_somebody_elses_data owner_name
          # single table inheritance assumes :type column but our existing tables often have that column already (and were not designed for STI anyway)
          self.inheritance_column = nil 

          # when the entire model is marked as read-only (i.e. a picklist) don't let records be persisted
          before_destroy :prevent_readonly_destroy   #destroy doesn't use the readonly? guard
          
          include ActiveRecord::Acts::SomebodyElsesData::InstanceMethods
          extend ActiveRecord::Acts::SomebodyElsesData::SingletonMethods
          
          self.set_owner owner_name
          
          cattr_accessor :all_readonly
        end
        
      end
      
      module SingletonMethods
        
        def stub_tables?
          ENVIRONMENTS_TO_STUB_TABLES.include? RAILS_ENV.to_sym
        end

        def set_owner schema
          @schema = schema
          set_table_name self.table_name
        end

        def set_table_name(value = nil, &block)
          if stub_tables?
            super value, &block
          else
            super "#{@schema.to_s}.#{value}", &block
          end
        end
        
        def set_all_readonly
          self.all_readonly = true
        end

      end
      
      module InstanceMethods
        def initialize(attributes = nil)
          obj = super
          readonly! if all_readonly
          obj
        end

        def prevent_readonly_destroy
          raise ActiveRecord::ReadOnlyRecord if  all_readonly
        end
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::Acts::SomebodyElsesData)
