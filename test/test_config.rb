require 'bundler/setup'
require 'test/unit'
require 'pp'
require 'logger'
require 'mocha'
require 'shoulda'
require 'active_record'
require 'active_model'
require 'restclient'
require 'database_cleaner'
require 'sc_mq/client/mq_client'
require 'sc_mq/rack/restbus_logger'
require 'sc_mq/inbound_message'
require 'sc_mq/outbound_message'
require 'sc_mq/outbound_message_group'
require 'sc_core/supply_chain'
require 'UUIDTools'
require 'multitenancy'

ROOT = File.expand_path("../..", __FILE__)
$:.unshift(ROOT + "/lib")

config = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'database.yml')))
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.establish_connection(config[ENV['DB'] || 'sqlite'])

class ActiveSupport::TestCase
  
  setup do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
    DatabaseCleaner.start
  end
  
  teardown do
    DatabaseCleaner.clean
  end
end