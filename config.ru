#\ -s puma

require "staticd/api"
require "staticd/http_server"

run Rack::URLMap.new '/api' => Staticd::API, '/' => Staticd::HTTPServer.new
