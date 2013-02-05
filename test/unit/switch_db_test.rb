require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

2.times do |i|
  ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations["db#{i + 1}".to_sym])
  ActiveRecord::Schema.define(:version => 1) do
    create_table :dummy, :force => true do |t|
      t.column :org_id, :string 
      t.column :name, :string
    end
  end
end

class Dummy < ActiveRecord::Base
end

class SwitchDBTest < Test::Unit::TestCase
  
  should "set current db name on switch db" do
    Dummy.switch_db(:db1) do
      assert_equal(:db1, Thread.current[:current_db])
    end
    Dummy.switch_db(:db2) do
      assert_equal(:db2, Thread.current[:current_db])
    end
  end
  
  should "reset current db after switch db is completed" do
    Dummy.switch_db(:db1) do
      assert_equal(:db1, Thread.current[:current_db])
    end
    assert_nil(Thread.current[:current_db])
  end
  
  should "clear active connections after switch db block execution" do
    ActiveRecord::ConnectionAdapters::ConnectionHandler.any_instance.expects(:clear_active_connections!)
    Dummy.switch_db(:db1) do
      assert_equal(:db1, Thread.current[:current_db])
    end
    assert_nil(Thread.current[:current_db])
  end
end