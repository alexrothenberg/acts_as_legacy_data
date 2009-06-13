class LegacyModelGenerator < Rails::Generator::NamedBase  
  def manifest
    record do |m|
      m.directory File.join('app/models', class_path)

      assigns = get_local_assigns
      m.template           'model.rb',      
                           File.join('app/models', class_path, "#{file_name}.rb"), 
                           :assigns => assigns
      m.migration_template 'migration.rb', 
                           'db/migrate',                                            
                           :assigns => assigns, :migration_file_name=> assigns[:migration_name].underscore
    end
  end

  
  private  
  def extract_modules(name)
    if name =~ /(.*)\.(.*)/
      @schema_name = $1
      name = $2
    end
    super(name)
  end
  
  
    def get_local_assigns
      returning(assigns = {}) do
        @class_name = $2 if class_name =~ /(.*)::(.*)$/
        assigns[:schema_name]         = @schema_name || class_nesting
        assigns[:table_name]          = "tb#{class_name.downcase}"
        assigns[:primary_key]         = "#{class_name.downcase}id"
        assigns[:attributes]          = get_legacy_schema(assigns[:schema_name], assigns[:table_name])
        assigns[:migration_name]      = "CreateStub#{class_name}Table"
      end
    end
    
    def get_legacy_schema schema, table
      legacy_model = Class.new(ActiveRecord::Base) do
        set_table_name "#{schema}.#{table}"
        establish_connection 'legacy'
      end
      legacy_model.columns
    end
end
