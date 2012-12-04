require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')

# Setup the db
ActiveRecord::Schema.define(:version => 1) do
  create_table :model_with_tenant_ids, :force => true do |t|
    t.column :org_id, :string 
    t.column :name, :string
  end
  
  create_table :model_with_sub_tenant_ids, :force => true do |t|
    t.column :seller_id, :string 
    t.column :name, :string
  end 

  create_table :model_with_tenant_id_and_sub_tenant_ids, :force => true do |t|
    t.column :org_id, :string 
    t.column :seller_id, :string 
    t.column :name, :string
  end
  
  create_table :model_without_tenant_id_and_sub_tenant_ids, :force => true do |t|
    t.column :name, :string
  end
end

class ModelWithTenantId < ActiveRecord::Base
  acts_as_tenant :org_id
end

class ModelWithoutTenantIdAndSubTenantId < ActiveRecord::Base
end

class ModelWithTenantIdAndSubTenantId < ActiveRecord::Base
  acts_as_tenant :org_id, :seller_id
end

class ModelWithSubTenantId < ActiveRecord::Base
  # acts_as_tenant nil, :seller_id
end

class ModelExtensionsTest < ActiveSupport::TestCase
    
    context "create model with tenant id and sub tenant id" do
      should "populate tenant and sub tenant id when set in context" do
        Multitenancy.with_tenant Multitenancy::Tenant.new('Flipkart', 'Poorvika') do
          model = ModelWithTenantIdAndSubTenantId.new({:name => "test name"})
          model.save!
          assert_equal 'Flipkart', model.org_id
          assert_equal 'Poorvika', model.seller_id
        end
      end
      
      should "populate only tenant when sub tenant is not set in context" do
        Multitenancy.with_tenant Multitenancy::Tenant.new('Flipkart') do
          model = ModelWithTenantIdAndSubTenantId.new({:name => "test name"})
          model.save!
          assert_equal 'Flipkart', model.org_id
          assert_nil model.seller_id
        end
      end
      
      should "not populate tenant and sub tenant when tenant id is not set in context" do
        Multitenancy.with_tenant Multitenancy::Tenant.new(nil, 'Poorvika') do
          model = ModelWithTenantIdAndSubTenantId.new({:name => "test name"})
          model.save!
          assert_nil model.org_id
          assert_nil model.seller_id
        end
      end
      
      should "not populate tenant and sub tenant when context is not set" do
        model = ModelWithTenantIdAndSubTenantId.new({:name => "test name"})
        model.save!
        assert_nil model.org_id
        assert_nil model.seller_id
      end
    end
    
    context "create model without tenant id and sub tenant id" do
      should "not populate tenant and sub tenant id when set in context" do
        Multitenancy.with_tenant Multitenancy::Tenant.new('Flipkart', 'Poorvika') do
          model = ModelWithoutTenantIdAndSubTenantId.new({:name => "test name"})
          model.save!
          assert_raises NoMethodError do 
            model.org_id
          end
          assert_raises NoMethodError do 
            model.seller_id
          end
        end
      end
      
      should "not populate tenant and sub tenant when context is not set" do
        model = ModelWithoutTenantIdAndSubTenantId.new({:name => "test name"})
        model.save!
        assert_raises NoMethodError do 
          model.org_id
        end
        assert_raises NoMethodError do 
          model.seller_id
        end
      end
    end
    
    context "create model only with tenant id" do
      should "populate tenant when set in context" do
        Multitenancy.with_tenant Multitenancy::Tenant.new('Flipkart') do
          model = ModelWithTenantId.new({:name => "test name"})
          model.save!
          assert_equal 'Flipkart', model.org_id
        end
      end
      
      should "not populate tenant when tenant id is not set in context" do
        Multitenancy.with_tenant Multitenancy::Tenant.new(nil) do
          model = ModelWithTenantId.new({:name => "test name"})
          model.save!
          assert_nil model.org_id
        end
      end
      
      should "not populate tenant when context is not set" do
        model = ModelWithTenantId.new({:name => "test name"})
        model.save!
        assert_nil model.org_id
      end
    end
    
    context "create model only with sub tenant id" do
      should "raise error when tenant id is nil" do
        model = ModelWithSubTenantId.new
        assert_raises RuntimeError do 
          ModelWithSubTenantId.acts_as_tenant nil
        end
      end
    end
    
    context "find by scope for model with tenant and sub tenant" do
      setup do
        Multitenancy.with_tenant Multitenancy::Tenant.new('Flipkart', 'Poorvika') do
          model = ModelWithTenantIdAndSubTenantId.new({:name => "test name"})
          model.save!
        end
        
        Multitenancy.with_tenant Multitenancy::Tenant.new('ebay', 'Poorvika') do
          model = ModelWithTenantIdAndSubTenantId.new({:name => "test name"})
          model.save!
        end
        
        Multitenancy.with_tenant Multitenancy::Tenant.new('ebay', 'Univercell') do
          model = ModelWithTenantIdAndSubTenantId.new({:name => "test name"})
          model.save!
        end
        
        Multitenancy.with_tenant Multitenancy::Tenant.new('Flipkart', nil) do
          model = ModelWithTenantIdAndSubTenantId.new({:name => "test name"})
          model.save!
        end
        
        model = ModelWithTenantIdAndSubTenantId.new({:name => "test name1"})
        model.save!
      end
      
      should "return by tenant id and sub tenant id when set in context" do
        Multitenancy.with_tenant Multitenancy::Tenant.new('Flipkart', 'Poorvika') do
          assert_equal 1, ModelWithTenantIdAndSubTenantId.all.count
          assert_equal 'Flipkart', ModelWithTenantIdAndSubTenantId.find_by_name('test name').org_id  
        end
        
        Multitenancy.with_tenant Multitenancy::Tenant.new('ebay', 'Univercell') do
          assert_equal 1, ModelWithTenantIdAndSubTenantId.all.count
        end
      end
      
      should "return by tenant id when sub tenant is not set in context" do
        Multitenancy.with_tenant Multitenancy::Tenant.new('Flipkart') do
          assert_equal 2, ModelWithTenantIdAndSubTenantId.all.count 
        end
        
        Multitenancy.with_tenant Multitenancy::Tenant.new('ebay') do
          assert_equal 2, ModelWithTenantIdAndSubTenantId.all.count
        end
      end
      
      should "return all when tenant id is not set in context" do
        Multitenancy.with_tenant Multitenancy::Tenant.new(nil, 'Poorvika') do
          assert_equal 5, ModelWithTenantIdAndSubTenantId.all.count 
          assert_equal 4, ModelWithTenantIdAndSubTenantId.where(:name => 'test name').count
        end
      end
    end
    
    context "find by scope for model with tenant" do
      setup do
        Multitenancy.with_tenant Multitenancy::Tenant.new('Flipkart') do
          model = ModelWithTenantIdAndSubTenantId.new({:name => "test name"})
          model.save!
        end
        
        Multitenancy.with_tenant Multitenancy::Tenant.new('ebay') do
          model = ModelWithTenantIdAndSubTenantId.new({:name => "test name1"})
          model.save!
        end
      end
      
      should "return by tenant id when set in context" do
        Multitenancy.with_tenant Multitenancy::Tenant.new('Flipkart') do
          assert_equal 1, ModelWithTenantIdAndSubTenantId.all.count 
        end
        
        Multitenancy.with_tenant Multitenancy::Tenant.new('ebay') do
          assert_equal 1, ModelWithTenantIdAndSubTenantId.all.count
        end
      end
      
      should "return all when tenant id is not set in context" do
        Multitenancy.with_tenant Multitenancy::Tenant.new(nil) do
          assert_equal 2, ModelWithTenantIdAndSubTenantId.all.count 
          assert_equal 1, ModelWithTenantIdAndSubTenantId.where(:name => 'test name').count
        end
      end
    end
end