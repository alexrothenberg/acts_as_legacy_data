RAILS_ENV = ENV["RAILS_ENV"] ||= "test" unless defined? RAILS_ENV

require 'rubygems'
require 'active_support'
require 'active_record'
require 'action_controller'
require 'action_controller/test_process'
require 'mocha'

Spec::Runner.configure do |config|
  config.mock_with :mocha
end
require 'lib/somebody_elses_data'

