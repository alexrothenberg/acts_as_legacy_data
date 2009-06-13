
require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class ReadOnlyModel < ActiveRecord::Base
  acts_as_legacy_data :some_owner

  set_all_readonly
  set_table_name :some_table

  def self.table_exists?
   true
  end
end

class UpdatableModel < ActiveRecord::Base
  acts_as_legacy_data :some_owner

  set_table_name :some_table

  def self.table_exists?
   true
  end
end


describe ActiveRecord::Acts::LegacyData do

  before :each do
    @mock_connection = stub(:columns=>[])
    ReadOnlyModel.stubs(:connection).returns(@mock_connection)
    UpdatableModel.stubs(:connection).returns(@mock_connection)
  end
  
  describe 'environments determine whether we are using the real database' do
    it 'should be stub database/tables and development environments' do
      ReadOnlyModel.stub_tables?.should be_true
    end

    it 'should not be stub database/tables in production environment' do
      silence_warnings { RAILS_ENV = 'production' }
      begin
        ReadOnlyModel.stub_tables?.should be_false
      ensure
        silence_warnings { RAILS_ENV = "test" }
      end
    end

    it 'should ignore schema prefix in test environment' do
      ReadOnlyModel.table_name.should == 'some_table'
    end

    it 'should set schema prefix in production environment' do
      silence_warnings { RAILS_ENV = 'production' }
      begin
        ReadOnlyModel.set_table_name :some_table
        ReadOnlyModel.table_name.should == 'some_owner.some_table'
      ensure
        silence_warnings { RAILS_ENV = "test" }
        ReadOnlyModel.set_table_name :some_table
      end
    end
  end

  describe 'read-only' do
    
    describe 'enforced on read-only model' do
      it 'should mark all new instances readonly when set_all_readonly' do
        ReadOnlyModel.new.should be_readonly
      end

      it 'should prevent updates on when marked readonly' do
        read_only_object = ReadOnlyModel.new
        @mock_connection.expects(:transaction).yields

        read_only_object.should be_readonly
        lambda { read_only_object.save }.should raise_error(ActiveRecord::ReadOnlyRecord)
      end

      it 'should be read only and not allow destroy on an object' do
        @mock_connection.expects(:transaction).yields

        read_only_object = ReadOnlyModel.new
        lambda { read_only_object.destroy }.should raise_error(ActiveRecord::ReadOnlyRecord)
      end
      
      it 'should be read only and not allow destroy using an id' do
        pending 'need to think about the mocking'

        lambda { ReadOnlyModel.destroy(1) }.should raise_error(ActiveRecord::ReadOnlyRecord)
      end
      
      it 'should be read only and not allow delete' do
        pending 'need to think about the mocking'

        lambda { ReadOnlyModel.delete(1) }.should raise_error(ActiveRecord::ReadOnlyRecord)
      end      
    end

    describe 'does not affect updatable models' do 
      it 'should not mark all new instances readonly when not setting set_all_readonly' do
        UpdatableModel.new.should_not be_readonly
      end

      it 'should not prevent updates on when marked readonly' do
        lambda { UpdatableModel.create() }.should_not raise_error(ActiveRecord::ReadOnlyRecord)
      end

      it 'should be read only and not allow destroy on an object' do
        model_object = UpdatableModel.new
        model_object.expects(:destroy).returns(true)
        lambda { model_object.destroy }.should_not raise_error(ActiveRecord::ReadOnlyRecord)
      end

      it 'should be read only and not allow destroy using an id' do
        pending 'need to setup a sqllite db so this succeeds'

        lambda { UpdatableModel.destroy(1) }.should raise_error(ActiveRecord::ReadOnlyRecord)
      end
      
      it 'should be read only and not allow delete' do
        pending 'need to setup a sqllite db so this succeeds'

        lambda { UpdatableModel.delete(1) }.should raise_error(ActiveRecord::ReadOnlyRecord)
      end
    end
  end
end


