require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

module Multitenancy
  class MultiTenancyTest < Test::Unit::TestCase
    
    should "configure headers" do
      Multitenancy.initialize(:tenant_header => 'tenant_id', :sub_tenant_header => 'seller_id')
      assert_equal 'tenant_id', Multitenancy.tenant_header
    end
    
    should "return current tenant" do
      tenant = Tenant.new('tenant_id', 'seller_id')
      Multitenancy.current_tenant = tenant
      assert_equal tenant, Multitenancy.current_tenant
    end
    
    context "block within context" do
      setup do
        tenant = Tenant.new('tenant_id', 'seller_id')
        Multitenancy.current_tenant = tenant
      end
      
      should "call block with right tenant and subtenant ids" do
        Multitenancy.with_tenant(Tenant.new('dummy_tenant_id', 'dummy_seller_id')) do 
          assert_equal Multitenancy.current_tenant.tenant_id, 'dummy_tenant_id'
          assert_equal Multitenancy.current_tenant.sub_tenant_id, 'dummy_seller_id'
        end
      end
    end
  end
end