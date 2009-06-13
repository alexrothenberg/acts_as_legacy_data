class <%= class_name -%> < ActiveRecord::Base
  acts_as_legacy_data :<%= schema_name %>
  set_table_name :<%= table_name %>
  set_primary_key :<%= primary_key %>
  # set sequence ...
  
  set_all_readonly
end
