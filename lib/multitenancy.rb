require "active_record"
require "active_model"

require "multitenancy/version"
require "multitenancy/tenant"
require "multitenancy/rack/filter"
require "multitenancy/model_extensions"

module Multitenancy
  
  @@tenant_header = 'X_TENANT_ID'
  @@sub_tenant_header = 'X_SUB_TENANT_ID'
  @@logger = (logger rescue nil) || Logger.new(STDOUT)

  class << self
    def initialize(config)
      @@tenant_header = config[:tenant_header]
      @@sub_tenant_header = config[:sub_tenant_header]
      @@logger = config[:logger] if config[:logger]
    end
    
    def logger
      @@logger
    end
  
    def tenant_header
      @@tenant_header
    end
    
    def sub_tenant_header
      @@sub_tenant_header
    end
    
    def with_tenant(tenant, &block)
      self.logger.debug "Executing the block with the tenant - #{tenant}"
      if block.nil?
        raise ArgumentError, "block required"
      end
      old_tenant = self.current_tenant
      self.current_tenant = tenant
      begin
        return block.call
      ensure
        self.current_tenant = old_tenant
      end
    end
    
    def current_tenant=(tenant)
      self.logger.debug "Setting the current tenant to - #{tenant}"
      Thread.current[:tenant] = tenant
    end
    
    def current_tenant
      Thread.current[:tenant]
    end
  end
end

if defined?(ActiveRecord::Base)
  ActiveRecord::Base.send(:include, Multitenancy::ModelExtensions)
end