class <%= migration_name %> < ActiveRecord::Migration
  def self.up
    if <%= class_name -%>.stub_tables?
      create_table :<%= table_name %>, :primary_key=>:<%= primary_key %> do |t|
  <% for attribute in attributes 
      unless attribute.name == primary_key -%>
      t.<%= attribute.type %> :<%= attribute.name %> 
  <% end 
  end -%>
    end
    else
      raise "DM probably needs to run a grant as it looks like #{<%= class_name -%>.table_name} doesn't exist" unless <%= class_name -%>.table_exists?
    end
  end

  def self.down
    if <%= class_name -%>.stub_tables?
      drop_table :<%= table_name %>
    end
  end
end

