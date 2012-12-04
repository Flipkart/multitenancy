module Multitenancy
  
  class Filter
    
    attr_reader :env, :app
    
    def initialize(app, env)
      @app = app
      @env = fix_headers!(env)
    end
    
    def call
      Multitenancy.with_tenant nil do
        @app.call env
      end
    end
    
    private
    # rack converts X_FOO to HTTP_X_FOO, so strip "HTTP_"
    def fix_headers!(env)
      env.keys.select { |k| k =~ /^HTTP_X_/ }.each do |k|
        env[k.gsub("HTTP_", "")] = env[k]
        env.delete(k)
      end
      env
    end
  end
end