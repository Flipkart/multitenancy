#--
# Copyright (c) 2007-2013 Flipkart.com
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

require "active_record"
require "active_model"
require "multitenancy/version"
require "multitenancy/active_record/switch_db"
require "multitenancy/tenant"
require "multitenancy/rack/filter"
require "multitenancy/model_extensions"
require "multitenancy/rest_client/rest_client.rb"

module Multitenancy
  
  @@tenant_header = 'X_TENANT_ID'
  @@sub_tenant_header = 'X_SUB_TENANT_ID'
  @@append_headers_to_rest_calls = true
  @@logger = (logger rescue nil) || Logger.new(STDOUT)
  @@db_config_prefix = ''
  @@db_config_suffix = '_development'
  @@db_type = :shared # or :dedicated

  class << self
    def init(config)
      @@tenant_header = config[:tenant_header]
      @@sub_tenant_header = config[:sub_tenant_header]
      @@logger = config[:logger] if config[:logger]
      @@append_headers_to_rest_calls = config[:append_headers_to_rest_calls] unless config[:append_headers_to_rest_calls].nil?
      @@db_config_prefix = config[:db_config_prefix] unless config[:db_config_prefix].nil?
      @@db_config_suffix = config[:db_config_suffix] unless config[:db_config_suffix].nil?
      @@db_type = (config[:db_type].nil? || ![:shared, :dedicated].include?(config[:db_type])) ? :shared : config[:db_type] 
    end
    
    def db_type
      @@db_type
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
    
    def append_headers_to_rest_calls?
      @@append_headers_to_rest_calls
    end
    
    def with_tenant(tenant, &block)
      self.logger.debug "Executing the block with the tenant - #{tenant}"
      if block.nil?
        raise ArgumentError, "block required"
      end
      old_tenant = self.current_tenant
      self.current_tenant = tenant
      begin
        if db_type == :shared
          return block.call
        else
          return ActiveRecord::Base.switch_db("#{@@db_config_prefix}#{tenant.tenant_id}#{@@db_config_suffix}".to_sym, &block)
        end
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
