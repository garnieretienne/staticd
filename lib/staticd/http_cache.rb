require "staticd/database"
require "staticd/cache_engine"

module Staticd

  # Rack middleware to manage remote HTTP resources caching.
  #
  # For each request, it will find the last release of the site associed with
  # the requested domain name and cache the corresponding resource if not
  # already cached.
  class HTTPCache
    include Staticd::Models

    def initialize(http_root, app)
      @app = app
      @http_root = http_root

      raise "No HTTP root folder provided" unless @http_root
      raise "No rack app provided" unless @app
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @env = env

      # Change the Request Path to '/index.html' if root path is asked.
      @env["PATH_INFO"] = "/index.html" if @env["PATH_INFO"] == '/'

      # Get the release from the request Host header.
      release = Release.last(
        Release.site.domain_names.name => Rack::Request.new(@env).host
      )
      return next_middleware unless release

      # Change the script name to include the site name and release version.
      @env["SCRIPT_NAME"] = "/#{release.site_name}/#{release}"

      req = Rack::Request.new(@env)
      cache_engine = CacheEngine.new(@http_root)

      # Do nothing else if the resource is already cached.
      return next_middleware if cache_engine.cached?(req.path)

      # Get the resource to cache.
      resource = Resource.first(
        Resource.routes.release_id => release.id,
        Resource.routes.path => req.path_info
      )
      return next_middleware unless resource

      # Cache the resource.
      cache_engine.cache(req.path, resource.url)
      next_middleware
    end

    private

    def next_middleware
      @app.call(@env)
    end
  end
end
