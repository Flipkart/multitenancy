require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

module Multitenancy
  class FilterTest < Test::Unit::TestCase
    
    setup do
      @env = {
        'X_TENANT_ID' => 'tenant_id',
        'X_SUB_TENANT_ID' => 'seller_id'
      }
      @app = mock
      @app.stubs(:call).with(@env).returns([:status, :headers, :body])
    end
    
    should "call app" do
      filter = Multitenancy::Filter.new(@app)
      assert_equal [:status, :headers, :body], filter.call(@env)
    end
  end
end