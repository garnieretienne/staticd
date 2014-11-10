require "staticd"

if ENV["STATICD_API_ENABLED"].nil? && ENV["STATICD_HTTP_ENABLED"].nil?
  ENV["STATICD_API_ENABLED"] = ENV["STATICD_HTTP_ENABLED"] = "true"
end

routes = {}
if ENV["STATICD_API_ENABLED"] == "true"
  puts "Staticd API service enabled (/api)"
  if ENV["RACK_ENV"].nil? || ENV["RACK_ENV"] == "development"
    puts "* Access ID: #{ENV["STATICD_ACCESS_ID"]}"
    puts "* Secret Key: #{ENV["STATICD_SECRET_KEY"]}"
  end
  routes['/api'] = Staticd::API
end
if ENV["STATICD_HTTP_ENABLED"] == "true"
  puts "Staticd HTTP service enabled (/)"
  http_root = ENV["STATICD_HTTP_CACHE"] || "/tmp/www"
  http_server = Staticd::HTTPServer.new(http_root)
  routes['/'] = Staticd::HTTPCache.new http_root, http_server
end


run Rack::URLMap.new routes
