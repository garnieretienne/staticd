require "staticd/database"
require "staticd/cache_engine"

# Rack middleware to manage remote resource caching
module Staticd
  class HTTPCache
    include Staticd::Model

    def initialize(http_root, app)
      @app = app
      @http_root = http_root
    end

    def call(env)
      @env = env

      # Get the site name from the request Host header
      site = Site.first(Site.domain_names.name => Rack::Request.new(@env).host)
      return next_middleware unless site
      @site_name = site.name

      # Change the Request Path to include the site name
      @env["SCRIPT_NAME"] = '/' + @site_name

      # Change the Request Path to '/index.html' if root is asked
      @env["PATH_INFO"] = '/index.html' if @env["PATH_INFO"] == '/'

      req = Rack::Request.new @env

      # Do nothing else if the resource is already cached
      if CacheEngine.cached? @http_root, req.path
        return next_middleware
      end

      # Get the resource to cache
      resource = Resource.first({
        Resource.release_maps.release.site_name => site.name,
        Resource.release_maps.path => req.path_info
      })
      return next_middleware unless resource

      # Cache the resource
      CacheEngine.cache @http_root, req.path, resource.url
      next_middleware
    end

    private

    def next_middleware
      status, headers, response = @app.call(@env)
    end
  end
end
