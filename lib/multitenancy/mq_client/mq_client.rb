module ScMq
  module Client
    class MqClient

      def send_message_with_headers(payload, http_method, request_uri, context=nil, correlation_id = nil, destination_response_status = nil, routing_key = nil, message_id = nil, group_id = nil, custom_headers = nil)
        custom_headers = Multitenancy.current_tenant.headers.to_json if custom_headers.nil? && Multitenancy.current_tenant && Multitenancy.current_tenant.tenant_id && Multitenancy.current_tenant.sub_tenant_id
        send_message_with_custom_headers(payload, http_method, request_uri, context, correlation_id, destination_response_status, routing_key, message_id, group_id, custom_headers)
      end

      alias_method :send_message_with_custom_headers, :send_message
      alias_method :send_message, :send_message_with_headers
    end
  end
end
