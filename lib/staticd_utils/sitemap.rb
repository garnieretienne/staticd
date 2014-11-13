require 'yaml'

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
              map[sha1] = object
            end
          end
        end
      end
      self.new map
    end

    def routes
      @map.map{|sha1, path| path}
    end

    def to_h
      @map
    end

    def to_yaml
      @map.to_yaml
    end
  end
end
