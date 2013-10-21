module Multitenancy
  
  class Filter
    
    def initialize(app)
      @app = app
    end
    
    def call(env)
      fix_headers!(env)
      tenant = Tenant.new env[Multitenancy.tenant_header], env[Multitenancy.sub_tenant_header]
      Multitenancy.with_tenant tenant do
        @app.call env
      end
    end
    
    private
    # rack converts X_FOO to HTTP_X_FOO, so strip "HTTP_"
    def fix_headers!(env)
      env.keys.select { |k| k =~ /^HTTP_X_/ }.each do |k|
        env[k.gsub("HTTP_X_", "")] = env[k]
        env.delete(k)
      end
      env
    end
  end
end