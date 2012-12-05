# Multitenancy

Multitenancy gem nicely plugs in to activerecord to provide multitenant support within a single schema. It allows multitenancy at two levels, tenant and sub-tenant. For instance you can have SAAS application where the primary tenant could be an organization and sub-tenant will be users in that organization. 

## Installation

Add this line to your application's Gemfile:

    gem 'multitenancy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install multitenancy

## Usage

This gem expects the tenant and sub-tenant values passed in the request header. But you can enhace this to support other logic as well.

You use it in your padrino/sinatra application, add the below lines to the config.ru
    
    Multitenancy.init(:tenant_header => 'X_COMPANY_ID', :sub_tenant_header => 'X_USER_ID')
    Padrino.use Multitenancy::Filter
    
You can also outside of a filter or in a standalone application,

    tenant = Multitenancy::Tenant.new('flipkart', 'ganeshs')
    Multitenancy.with_tenant(tenant) do
        # Your code here
    end
    
Any active record query executed within the tenant block, will be tenant/sub-tenant scoped. New records will persist the tenant and sub-tenant ids, find queries will be scoped to teanant and sub-tenant ids. If the sub-tenant id is not specified, it will be de-scoped.
    
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
