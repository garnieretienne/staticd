require 'digest/md5'
require "staticd_utils/archive"

module Staticd
  class CacheEngine

    CACHE_DIR = "/tmp/cache"

    def self.cache(url)
      init
      if File.directory? cache_path(url)
        FileUtils.rm_r cache_path(url), force: true, secure: true
      end
      archive = StaticdUtils::Archive.open_file url
      archive.extract cache_path(url)
      cache_path(url)
    end

    def self.init
      FileUtils.mkdir_p CACHE_DIR
    end

    # Move into an instance method to be able to cache the md5 digest
    def self.cache_path(url)
      "#{CACHE_DIR}/#{Digest::MD5.hexdigest(url)}"
    end

    def self.reset!
      FileUtils.rm_r Dir.glob("#{CACHE_DIR}/*")
    end

    def self.cached?(url)
      Dir.exist?(cache_path(url)) ? cache_path(url) : false
    end

    def self.purge(url)
      if File.directory? cache_path(url)
        FileUtils.rm_r cache_path(url)
        true
      else
        false
      end
    end
  end
end
