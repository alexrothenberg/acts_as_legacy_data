
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe ActiveRecord::Acts::SomebodyElsesData do

  class ReadOnlyModel < ActiveRecord::Base
   acts_as_somebody_elses_data :some_owner
   
   set_all_readonly
   set_table_name :some_table
   
   def self.table_exists?
     true
   end
 end
 
 class UpdatableModel < ActiveRecord::Base
   acts_as_somebody_elses_data :some_owner

   set_table_name :some_table

   def self.table_exists?
     true
   end
 end

 it 'should stub other tables in test and development environments' do
   ReadOnlyModel.stub_tables?.should be_true
 end
 
 it 'should not stub other tables in production environment' do
   silence_warnings { RAILS_ENV = 'production' }
   begin
     ReadOnlyModel.stub_tables?.should be_false
   ensure
     silence_warnings { RAILS_ENV = "test" }
   end
 end
 
 it 'should set table name using schema prefix in production environment' do
   silence_warnings { RAILS_ENV = 'production' }
   begin
     ReadOnlyModel.set_table_name :some_table
     ReadOnlyModel.table_name.should == 'some_owner.some_table'
   ensure
     silence_warnings { RAILS_ENV = "test" }
     ReadOnlyModel.set_table_name :some_table
   end
 end
 
 it 'should set table name ignoring schema prefix in test environment' do
   ReadOnlyModel.table_name.should == 'some_table'
 end
 
 it 'should mark all new instances readonly when set_all_readonly' do
   ReadOnlyModel.stubs(:connection).returns(mock(:columns=>[]))
   ReadOnlyModel.new.should be_readonly
 end
 
 it 'should not mark all new instances readonly when not setting set_all_readonly' do
   UpdatableModel.stubs(:connection).returns(mock(:columns=>[]))
   UpdatableModel.new.should_not be_readonly
 end
 
 it 'should prevent updates on when marked readonly' do
   ReadOnlyModel.stubs(:connection).returns(connection=mock)
   read_only_object = ReadOnlyModel.new
   connection.expects(:transaction).yields

   read_only_object.should be_readonly
   lambda { read_only_object.save }.should raise_error(ActiveRecord::ReadOnlyRecord)
 end
 
 it 'should not prevent updates on when marked readonly' do
   UpdatableModel.stubs(:connection).returns(connection=mock)
   
   lambda { UpdatableModel.create() }.should_not raise_error(ActiveRecord::ReadOnlyRecord)
 end
 
 it 'should be read only and not allow destroying' do
   ReadOnlyModel.stubs(:connection).returns(connection=mock)
   connection.expects(:transaction).yields

   read_only_object = ReadOnlyModel.new
   lambda { read_only_object.destroy }.should raise_error(ActiveRecord::ReadOnlyRecord)
 end
 
 it 'should be read only and not allow destroying' do
   UpdatableModel.stubs(:connection).returns(connection=mock)
   model_object = UpdatableModel.new
   model_object.expects(:destroy).returns(true)
   lambda { model_object.destroy }.should_not raise_error(ActiveRecord::ReadOnlyRecord)
 end
 
 
end


