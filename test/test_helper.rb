ENV['RACK_ENV'] = "test"

require "test/unit"
require "rack/test"

module TestHelper
  include Rack::Test::Methods

  def root_path
    File.expand_path File.dirname(__FILE__)
  end

  def fixtures_path(fixture)
    "#{root_path}/fixtures/#{fixture}"
  end
end
