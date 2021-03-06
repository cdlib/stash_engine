require 'test_helper'

module StashEngine
  class TenantTest < ActiveSupport::TestCase
    test 'tenants loaded' do
      assert_equal 3, Tenant.all.length
      assert_equal Tenant.all.first.tenant_id, 'dataone'
    end

    test 'find' do
      assert_instance_of StashEngine::Tenant, Tenant.find('ucb')
      assert_equal 'UC Berkeley', Tenant.find('ucb').short_name
    end

    test 'login_path' do
      assert_instance_of String, Tenant.find('ucb').omniauth_login_path
      assert_instance_of String, Tenant.find('dataone').omniauth_login_path
    end

    test 'tenant_by_domain' do
      assert_instance_of StashEngine::Tenant, Tenant.by_domain('oneshare-aws-dev.cdlib.org')
      assert_equal 'DataONE', Tenant.by_domain('catfood.oneshare-aws-dev.cdlib.org').short_name
    end

    test 'landing_url' do
      ucb = Tenant.find('ucb')
      assert_equal "https://dash2-dev.cdlib.org/catfun/dogfun", ucb.landing_url('/catfun/dogfun')
    end
  end
end
