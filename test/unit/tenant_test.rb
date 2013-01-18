require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

module Multitenancy
  class TenantTest < Test::Unit::TestCase

    setup() do
       Multitenancy.init({:tenant_header => 'X_TENANT_ID', :sub_tenant_header => 'X_SUB_TENANT_ID'})
    end
  
    should "create tenant" do
      tenant = Tenant.new('tenant_id', 'seller_id')
      assert_equal tenant.tenant_id, 'tenant_id'
      assert_equal tenant.sub_tenant_id, 'seller_id'
    end
    
    should "get headers" do
      tenant = Tenant.new('tenant_id', 'seller_id')
      assert_equal tenant.headers, {'X_TENANT_ID' => 'tenant_id', 'X_SUB_TENANT_ID' => 'seller_id'}
    end
    
    should "not allow setting tenant and sub tenant id" do
      tenant = Tenant.new('tenant_id', 'seller_id')
      assert_raises NoMethodError do
        tenant.tenant_id = 'test'
      end
      assert_raises NoMethodError do
        tenant.sub_tenant_id = 'test'
      end
    end
  end
end