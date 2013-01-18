module RestClient
  class Request
    
    class << self
      
      def execute_with_tenant_headers(args, &block)
        args[:headers] = append_tenant_headers(args[:headers]) if Multitenancy.current_tenant && Multitenancy.append_headers_to_rest_calls?
        return execute_without_tenant_headers(args, &block)
      end

      alias_method :execute_without_tenant_headers, :execute      
      alias_method :execute, :execute_with_tenant_headers
      
      private
      def append_tenant_headers(headers)
        headers ||= {}
        if !headers[Multitenancy.tenant_header] && Multitenancy.current_tenant
          headers[Multitenancy.tenant_header] = Multitenancy.current_tenant.tenant_id
        end
        
        if !headers[Multitenancy.sub_tenant_header] && Multitenancy.current_tenant
          headers[Multitenancy.sub_tenant_header] = Multitenancy.current_tenant.sub_tenant_id
        end
        headers
      end
    end
    
  end
end