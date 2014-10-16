require "staticd/database"
require "staticd/cache_engine"

module Staticd
  class HTTPServer
    include Model

    def call(env)

      # Get the domain name
      req = Rack::Request.new env
      domain_name = DomainName.get req.host

      # Find the corresponding site and release
      site = domain_name.site
      last_release = site.releases.last

      # Verify the site is cached
      local_path = CacheEngine.cached? last_release.url
      unless local_path
        local_path = CacheEngine.cache last_release.url
      end

      # Serve the requested file if exist
      path = (req.path == "/") ? 'index.html' : req.path
      file_path = "#{local_path}/#{path}"
      send file_path
    end

    def send(file)
      if File.readable? file
        res = Rack::Response.new
        File.foreach(file){|chunk| res.write chunk}
        res.finish
      else
        res = Rack::Response.new ["Not Found"], 404, {}
        res.finish
      end
    end
  end
end
