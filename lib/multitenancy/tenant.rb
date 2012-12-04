module Multitenancy
  
  class Tenant
    attr_reader :tenant_id, :sub_tenant_id
    
    def initialize(tenant_id, sub_tenant_id=nil)
      @tenant_id = tenant_id
      @sub_tenant_id = sub_tenant_id
    end
    
    def headers
      {Multitenancy.tenant_header => tenant_id, Multitenancy.sub_tenant_header => sub_tenant_id}
    end
  end
end