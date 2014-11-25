require 'yaml'
require 'digest/sha1'
require "staticd_utils/memory_file"

module StaticdUtils

  class Sitemap

    def initialize(map)
      @map = map
    end

    def self.create(path)
      map = {}
      if File.directory?(path)
        Dir.chdir path do
          Dir["**/*"].each do |object|
            if File.file?(object)
              sha1 = Digest::SHA1.hexdigest(File.read(object))
              map[sha1] = "/#{object}"
            end
          end
        end
      end
      self.new map
    end

    def self.open(yaml)
      self.new YAML.load(yaml)
    end

    def self.open_file(path)
      open(File.read(path))
    end

    def routes
      @map.map{|sha1, path| path}
    end

    def digests
      @map.map{|sha1, path| sha1}
    end

    def each_resources(&block)
      @map.each{|key, value| yield key, value}
    end

    def to_h
      @map
    end

    def to_yaml
      @map.to_yaml
    end

    def to_memory_file
      StaticdUtils::MemoryFile.new StringIO.new(to_yaml)
    end
  end
end
