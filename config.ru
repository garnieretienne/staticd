require "staticd"

# Quick fix on database url using 'postgresql://' scheme which is not recognized
# by datamapper.
ENV["STATICD_DATABASE"] = ENV["STATICD_DATABASE"].sub(
  "postgresql://", "postgres://"
)

# Default values:
# * Enable Staticd API service
# * Enable Staticd HTTP service
# * Run the app in development environment
ENV["STATICD_API_ENABLED"] ||= "true"
ENV["STATICD_HTTP_ENABLED"] ||= "true"
ENV["RACK_ENV"] ||= "development"

# Verify every needed configuration is specified.
Staticd::Config.verify("STATICD_DATABASE", "STATICD_DATASTORE")

routes = {}

# Start the Staticd API service.
if ENV["STATICD_API_ENABLED"] == "true"

  # Verify every needed configuration for the API service is specified.
  Staticd::Config.verify(
    "STATICD_WILDCARD_DOMAIN", "STATICD_ACCESS_ID", "STATICD_SECRET_KEY"
  )

  mount_point = "/api"
  routes[mount_point] = Staticd::API
  puts "Staticd API service enabled (#{mount_point})."
end

# Start the Staticd HTTP service.
if ENV["STATICD_HTTP_ENABLED"] == "true"

  # Verify every needed configuration for the HTTP service is specified.
  Staticd::Config.verify("STATICD_HTTP_CACHE")

  mount_point = "/"
  http_server = Staticd::HTTPServer.new(ENV["STATICD_HTTP_CACHE"])
  http_cache = Staticd::HTTPCache.new(ENV["STATICD_HTTP_CACHE"], http_server)
  routes[mount_point] = http_cache
  puts "Staticd HTTP service enabled (#{mount_point})."
end

# Display current configuration if in development environment.
if ENV["RACK_ENV"] == "development"
  puts "Configuration:"

  if ENV["STATICD_API_ENABLED"] == "true"
    puts "* Wildcard domain: #{ENV["STATICD_WILDCARD_DOMAIN"]}"
    puts "* Access ID: #{ENV["STATICD_ACCESS_ID"]}"
    puts "* Secret Key: #{ENV["STATICD_SECRET_KEY"]}"
  end

  if ENV["STATICD_HTTP_ENABLED"] == "true"
    puts "* HTTP cache: #{ENV["STATICD_HTTP_CACHE"]}"
  end

  puts "* Database: #{ENV["STATICD_DATABASE"]}"
  puts "* Datastore: #{ENV["STATICD_DATASTORE"]}"
end

# Initialize database.
Staticd::Database.init_database(ENV["RACK_ENV"], ENV["STATICD_DATABASE"])

# Start the engine.
run Rack::URLMap.new(routes)
