require 'bundler/setup'
require 'test/unit'
require 'pp'
require 'logger'
require 'mocha'
require 'shoulda'
require 'active_record'
require 'active_model'
require 'restclient'
require 'multitenancy'
require 'database_cleaner'

ROOT = File.expand_path("../..", __FILE__)
$:.unshift(ROOT + "/lib")

config = YAML::load(IO.read(File.join(File.dirname(__FILE__), 'database.yml')))
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))
ActiveRecord::Base.configurations[:db1] = config[ENV['DB1'] || 'db1']
ActiveRecord::Base.configurations[:db2] = config[ENV['DB2'] || 'db2']
ActiveRecord::Base.establish_connection(ActiveRecord::Base.configurations[:db1])

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