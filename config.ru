require "staticd"
require "tmpdir"

# Enable Staticd API service
ENV["STATICD_API_ENABLED"] ||= "true"

# Default wildcard domain
ENV["STATICD_WILDCARD_DOMAIN"] ||= "local"

# Access ID used to authenticate client in the API service
ENV["STATICD_ACCESS_ID"] ||= "1000"

# Secret Key used to authenticate client in the API service
ENV["STATICD_SECRET_KEY"] ||= "staticd"

# Enable Staticd HTTP service
ENV["STATICD_HTTP_ENABLED"] ||= "true"

# Directory used to cache HTTP resources locally
ENV["STATICD_HTTP_CACHE"] ||= Dir.mktmpdir

# Environment
ENV["RACK_ENV"] ||= "development"

# Database URL
ENV["STATICD_DATABASE"] ||= "sqlite::memory:"

# Datastore URL
ENV["STATICD_DATASTORE"] ||= Dir.mktmpdir

routes = {}

if ENV["STATICD_API_ENABLED"] == "true"

  puts "Staticd API service enabled (/api)"

  if ENV["RACK_ENV"] == "development"
    puts "* Wildcard domain: #{ENV["STATICD_WILDCARD_DOMAIN"]}"
    puts "* Access ID: #{ENV["STATICD_ACCESS_ID"]}"
    puts "* Secret Key: #{ENV["STATICD_SECRET_KEY"]}"
  end

  routes['/api'] = Staticd::API
end

if ENV["STATICD_HTTP_ENABLED"] == "true"

  puts "Staticd HTTP service enabled (/)"

  if ENV["RACK_ENV"] == "development"
    puts "* Using #{ENV["STATICD_HTTP_CACHE"]} as HTTP cache"
  end

  http_server = Staticd::HTTPServer.new ENV["STATICD_HTTP_CACHE"]
  http_cache = Staticd::HTTPCache.new ENV["STATICD_HTTP_CACHE"], http_server
  routes['/'] = http_cache
end


if ENV["RACK_ENV"] == "development"
  puts "Other components configuration:"
  puts "* Database: #{ENV["STATICD_DATABASE"]}"
  puts "* Datastore: #{ENV["STATICD_DATASTORE"]}"
end
extend Staticd::Database
init_database ENV["RACK_ENV"], ENV["STATICD_DATABASE"]

run Rack::URLMap.new routes
