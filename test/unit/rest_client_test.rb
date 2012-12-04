require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class RestClientTest < Test::Unit::TestCase

  setup do
    Multitenancy.initialize({:tenant_header => 'X_COMPANY_ID', :sub_tenant_header => 'X_USER_ID'})
  end
  
  should "append tenant headers to rest calls within a tenant scope" do
    RestClient::Request.any_instance.expects(:make_headers).with() {|headers| headers[Multitenancy.tenant_header] == 'Flipkart' && headers[Multitenancy.sub_tenant_header] == 'ganeshs'}
    RestClient::Request.any_instance.expects(:execute)
    Multitenancy.with_tenant(Multitenancy::Tenant.new('Flipkart', 'ganeshs')) do
      RestClient.get('http://some/resource')
    end
  end
  
  should "not append tenant headers to rest calls outside of a tenant scope" do
    RestClient::Request.any_instance.expects(:make_headers).with() {|headers| headers[Multitenancy.tenant_header].nil? && headers[Multitenancy.sub_tenant_header].nil? }
    RestClient::Request.any_instance.expects(:execute)
    RestClient.get('http://some/resource')
  end
  
  context "no tenant headers in rest calls" do
    setup do
      Multitenancy.initialize({:tenant_header => 'X_COMPANY_ID', :sub_tenant_header => 'X_USER_ID', :append_headers_to_rest_calls => false})
    end
    
    should "not append tenant headers to rest calls within tenant scope" do
      RestClient::Request.any_instance.expects(:make_headers).with() {|headers| headers[Multitenancy.tenant_header].nil? && headers[Multitenancy.sub_tenant_header].nil? }
      RestClient::Request.any_instance.expects(:execute)
      Multitenancy.with_tenant(Multitenancy::Tenant.new('Flipkart', 'ganeshs')) do
        RestClient.get('http://some/resource')
      end
    end
  end
    
end