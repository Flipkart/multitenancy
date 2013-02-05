require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

module Multitenancy
  class MultiTenancyTest < Test::Unit::TestCase
    
    should "configure headers" do
      Multitenancy.init(:tenant_header => 'tenant_id', :sub_tenant_header => 'seller_id')
      assert_equal 'tenant_id', Multitenancy.tenant_header
    end
    
    context "configure db type" do
      should "default to shared" do
        Multitenancy.init(:tenant_header => 'tenant_id', :sub_tenant_header => 'seller_id')
        assert_equal :shared, Multitenancy.db_type
      end
      
      should "set to shared on junk value" do
        Multitenancy.init(:tenant_header => 'tenant_id', :sub_tenant_header => 'seller_id', :db_type => :junk)
        assert_equal :shared, Multitenancy.db_type 
      end
      
      should "set to dedicated" do
        Multitenancy.init(:tenant_header => 'tenant_id', :sub_tenant_header => 'seller_id', :db_type => :dedicated)
        assert_equal :dedicated, Multitenancy.db_type
      end
    end
    
    should "return current tenant" do
      tenant = Tenant.new('tenant_id', 'seller_id')
      Multitenancy.current_tenant = tenant
      assert_equal tenant, Multitenancy.current_tenant
    end
    
    context "block within context" do
      setup do
        Multitenancy.init(:tenant_header => 'tenant_id', :sub_tenant_header => 'seller_id')
        tenant = Tenant.new('tenant_id', 'seller_id')
        Multitenancy.current_tenant = tenant
      end
      
      should "call block with right tenant and subtenant ids" do
        Multitenancy.with_tenant(Tenant.new('dummy_tenant_id', 'dummy_seller_id')) do 
          assert_equal Multitenancy.current_tenant.tenant_id, 'dummy_tenant_id'
          assert_equal Multitenancy.current_tenant.sub_tenant_id, 'dummy_seller_id'
        end
      end
      
      context "for dedicated db" do
        setup do
          Multitenancy.init(:tenant_header => 'tenant_id', :sub_tenant_header => 'seller_id', :db_type => :dedicated)
        end
        
        should "switch db" do
          ActiveRecord::Base.expects(:switch_db).with(:db1_development)
          Multitenancy.with_tenant(Tenant.new('db1')) do
          end
        end
        
        should "call block" do
          test = false
          ActiveRecord::Base.stubs(:establish_connection)
          Multitenancy.with_tenant(Tenant.new('db1')) do
            test = true
          end
          assert_true test
        end
        
      end
    end
    
    context "for dedicated type prefix and suffix" do
      setup do
        Multitenancy.init(:tenant_header => 'tenant_id', :sub_tenant_header => 'seller_id', :db_type => :dedicated, :db_config_prefix => 'db_', :db_config_suffix => '_suffix')
      end
    
      should "be used to switch db" do
        ActiveRecord::Base.expects(:switch_db).with(:db_db1_suffix)
        Multitenancy.with_tenant(Tenant.new('db1')) do
        end
      end
    end
  end
end