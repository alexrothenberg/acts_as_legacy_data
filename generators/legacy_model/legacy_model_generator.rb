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

      add_factory class_name, assigns[:attributes]
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
  
  def add_factory factory_name, columns
    File.open('spec/factories.rb', 'a') do |file| 
      file.write "Factory.define :#{factory_name} do |#{factory_name.to_s.first}|\n"
      columns.each do |c|
        if c.null == false
          value = case c.type
          when :integer
            "7"
          when :string
            "'hi'"
          when :boolean
            'false'
          when :date
            '{Time.now}'
          when :datetime
            '{Time.now}'
          else
            raise "forgot about #{c.type}"
          end
          file.write "  #{factory_name.to_s.first}.#{c.name} #{value}\n"
        end
      end
      file.write "end\n\n"
    end
  end
end
