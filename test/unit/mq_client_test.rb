require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

class MqClientTest < Test::Unit::TestCase

  setup do
    SupplyChain.stubs(:url).returns('http://abc/def')
  end

  def test_send_message_with_multitenancy_and_no_explicit_headers
    Multitenancy.with_tenant Multitenancy::Tenant.new('FKMP', 'wsr') do

      mq_client = ScMq::Client::MqClient.new('app_id_1', 'a.b.c.d.', nil, nil)
      mq_client.expects(:send_message_with_custom_headers).with(anything, anything, anything,
                                                                anything, anything, anything,
                                                                anything, anything, anything,
                                                                {'X_TENANT_ID' => 'FKMP', 'X_SUB_TENANT_ID' => 'wsr'}.to_json)
      mq_client.send_message({}, 'POST', 'http://abc/def')
    end
  end

  def test_send_message_with_multitenancy_and_explicit_headers
    Multitenancy.with_tenant Multitenancy::Tenant.new('FKMP', 'wsr') do

      mq_client = ScMq::Client::MqClient.new('app_id_1', 'a.b.c.d.', nil, nil)
      mq_client.expects(:send_message_with_custom_headers).with(anything, anything, anything,
                                                                anything, anything, anything,
                                                                anything, anything, anything,
                                                                {'X_TENANT_ID' => 'ABC', 'X_SUB_TENANT_ID' => 'xyz'}.to_json)
      mq_client.send_message({}, 'POST', 'http://abc/def', nil, nil, nil, nil, nil, nil, {'X_TENANT_ID' => 'ABC', 'X_SUB_TENANT_ID' => 'xyz'}.to_json)
    end
  end

  def test_send_message_with_no_tenant_and_custom_headers
    Multitenancy.with_tenant nil do

      mq_client = ScMq::Client::MqClient.new('app_id_1', 'a.b.c.d.', nil, nil)
      mq_client.expects(:send_message_with_custom_headers).with(anything, anything, anything,
                                                                anything, anything, anything,
                                                                anything, anything, anything,
                                                                {'X_TENANT_ID' => 'ABC', 'X_SUB_TENANT_ID' => 'xyz'}.to_json)
      mq_client.send_message({}, 'POST', 'http://abc/def', nil, nil, nil, nil, nil, nil, {'X_TENANT_ID' => 'ABC', 'X_SUB_TENANT_ID' => 'xyz'}.to_json)
    end
  end


  def test_send_message_with_no_tenant_and_no_headers
    Multitenancy.with_tenant nil do
      mq_client = ScMq::Client::MqClient.new('app_id_1', 'a.b.c.d.', nil, nil)
      mq_client.expects(:send_message_with_custom_headers).with(anything, anything, anything,
                                                                anything, anything, anything,
                                                                anything, anything, anything,
                                                                nil)
      mq_client.send_message({}, 'POST', 'http://abc/def', nil, nil, nil, nil, nil, nil)
    end
  end


  def test_send_message_with_empty_tenant_and_no_headers
    Multitenancy.with_tenant Multitenancy::Tenant.new(nil, nil) do

      mq_client = ScMq::Client::MqClient.new('app_id_1', 'a.b.c.d.', nil, nil)
      mq_client.expects(:send_message_with_custom_headers).with(anything, anything, anything,
                                                                anything, anything, anything,
                                                                anything, anything, anything,
                                                                nil)
      mq_client.send_message({}, 'POST', 'http://abc/def', nil, nil, nil, nil, nil, nil)
    end
  end


  def test_send_message_with_empty_tenant_and_custom_headers
    Multitenancy.with_tenant Multitenancy::Tenant.new(nil, nil) do

      mq_client = ScMq::Client::MqClient.new('app_id_1', 'a.b.c.d.', nil, nil)
      mq_client.expects(:send_message_with_custom_headers).with(anything, anything, anything,
                                                                anything, anything, anything,
                                                                anything, anything, anything,
                                                                {'X_TENANT_ID' => 'ABC', 'X_SUB_TENANT_ID' => 'xyz'}.to_json)
      mq_client.send_message({}, 'POST', 'http://abc/def', nil, nil, nil, nil, nil, nil, {'X_TENANT_ID' => 'ABC', 'X_SUB_TENANT_ID' => 'xyz'}.to_json)
    end
  end

  def test_send_message_with_only_tenant_and_no_custom_headers
    Multitenancy.with_tenant Multitenancy::Tenant.new('FKMP', nil) do

      mq_client = ScMq::Client::MqClient.new('app_id_1', 'a.b.c.d.', nil, nil)
      mq_client.expects(:send_message_with_custom_headers).with(anything, anything, anything,
                                                                anything, anything, anything,
                                                                anything, anything, anything,
                                                                nil)
      mq_client.send_message({}, 'POST', 'http://abc/def', nil, nil, nil, nil, nil, nil)
    end
  end

  def test_send_message_with_onlu_sub_tenant_and_no_custom_headers
    Multitenancy.with_tenant Multitenancy::Tenant.new(nil, 'wsr') do

      mq_client = ScMq::Client::MqClient.new('app_id_1', 'a.b.c.d.', nil, nil)
      mq_client.expects(:send_message_with_custom_headers).with(anything, anything, anything,
                                                                anything, anything, anything,
                                                                anything, anything, anything,
                                                                nil)
      mq_client.send_message({}, 'POST', 'http://abc/def', nil, nil, nil, nil, nil, nil)
    end
  end

end