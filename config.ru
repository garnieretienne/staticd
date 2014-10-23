#\ -s puma

require "staticd"

if ENV["STATICD_API_ENABLED"].nil? && ENV["STATICD_HTTP_ENABLED"].nil?
  ENV["STATICD_API_ENABLED"] = ENV["STATICD_HTTP_ENABLED"] = "true"
end

routes = {}
if ENV["STATICD_API_ENABLED"] == "true"
  puts "Staticd API service enabled (/api)"
  routes.merge '/api' => Staticd::API
end
if ENV["STATICD_HTTP_ENABLED"] == "true"
  puts "Staticd HTTP service enabled (/)"
  routes.merge '/' => Staticd::HTTPServer.new
end


run Rack::URLMap.new routes
