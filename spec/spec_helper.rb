ENV['RACK_ENV'] = 'test'

require 'rspec'
require 'rack/test'
require 'pry'

$LOAD_PATH << File.expand_path(File.join(__dir__, '..'))

module RSpecMixin
end

RSpec.configure do |c|
  c.include RSpecMixin
  c.include Rack::Test::Methods
end
