require "staticd/api"

run Rack::URLMap.new '/api' => Staticd::API
