require "open-uri"
require "sendfile"

module Staticd

  # Class to manage HTTP resources caching.
  #
  # Example:
  #   cache_engine = CacheEngine.new("/tmp/cache")
  #   unless cache.cached?("/index.html")
  #     cache_engine.cache("/index.html", "http://storage.tld/0000000")
  #   end
  #
  # TODO: add a purge method based on file's atime attribute
  class CacheEngine

    def initialize(http_root)
      @http_root = http_root
      check_cache_directory
    end

    def cache(resource_path, resource_url)
      open(resource_url, "rb") do |resource|
        FileUtils.mkdir_p(File.dirname(local_path(resource_path)))
        File.open(local_path(resource_path), "w+") do |file|
          resource.each { |chunk| file.write(chunk) }
        end
      end
    end

    def cached?(resource_path)
      File.exist?(local_path(resource_path))
    end

    private

    def local_path(resource_path)
      @http_root + resource_path
    end

    def check_cache_directory
      FileUtils.mkdir_p(@http_root) unless File.directory?(@http_root)
    end
  end
end
