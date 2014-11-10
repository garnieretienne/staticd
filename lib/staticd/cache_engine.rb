require 'open-uri'

module Staticd

  # TODO: add a purge method based on file's atime attribute
  class CacheEngine

    def self.cache(http_root, resource_path, resource_url)
      local_resource_path = "#{http_root}/#{resource_path}"
      init(File.dirname(local_resource_path))
      open(resource_url) do |remote_file|
        File.open("#{http_root}/#{resource_path}", "w+") do |cached_file|
          cached_file.write remote_file.read
        end
      end
      local_resource_path
    end

    def self.init(cache_path)
      FileUtils.mkdir_p cache_path
    end

    def self.cached?(http_root, resource_path)
      File.exist? "#{http_root}/#{resource_path}"
    end
  end
end
