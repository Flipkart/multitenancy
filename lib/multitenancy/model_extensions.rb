module Multitenancy
  
  class << self
    attr_accessor :tenant_field, :sub_tenant_field
  end
  
  module ModelExtensions
    extend ActiveSupport::Concern
    
    module ClassMethods
      
      def acts_as_tenant(tenant_id, sub_tenant_id=nil)
        raise "tenant_id can't be nil! [Multitenancy]" unless tenant_id
        
        def self.is_scoped_by_tenant?
          true
        end
        
        Multitenancy.tenant_field = tenant_id
        Multitenancy.sub_tenant_field = sub_tenant_id
        
        # set the current_tenant on newly created objects
        before_validation Proc.new {|m|
          tenant = Multitenancy.current_tenant
          return unless tenant && tenant.tenant_id
          m.send "#{tenant_id}=".to_sym, tenant.tenant_id
          m.send "#{sub_tenant_id}=".to_sym, tenant.sub_tenant_id unless sub_tenant_id.nil?
        }, :on => :create
        
        # set the default_scope to scope to current tenant
        default_scope lambda {
          tenant = Multitenancy.current_tenant
          if tenant && tenant.tenant_id
            conditions = {}
            conditions[tenant_id] = tenant.tenant_id
            conditions[sub_tenant_id] = tenant.sub_tenant_id if sub_tenant_id && tenant.sub_tenant_id
            where(conditions)
          end
        }
        
        # Rewrite accessors to make tenantimmutable
        define_method "#{tenant_id}=" do |value|
          if new_record?
            write_attribute(tenant_id, value)
          else
            raise "#{tenant_id} is immutable! [Multitenancy]"
          end
        end
        
        # Rewrite accessors to make sub_tenant immutable
        define_method "#{sub_tenant_id}=" do |value|
          if new_record?
            write_attribute(sub_tenant_id, value)
          else
            raise "#{sub_tenant_id} is immutable! [Multitenancy]"
          end
        end
      end
      
      def validates_uniqueness_to_tenant(fields, args ={})
        raise "[Multitenancy] validates_uniqueness_to_tenant: no current tenant" unless respond_to?(:is_scoped_by_tenant?)
        tenant_id = lambda {Multitenancy.tenant_field.downcase}.call
        sub_tenant_id = Multitenancy.sub_tenant_field ? lambda {Multitenancy.sub_tenant_field.downcase}.call : nil 
        
        if args[:scope].nil?
          args[:scope] = [tenant_id]
        else
          args[:scope] << tenant_id
        end
        args[:scope] = sub_tenant_id if sub_tenant_id
        validates_uniqueness_of(fields, args)
      end
    end
  end
end