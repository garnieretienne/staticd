require "digest/sha1"
require "yaml"
require "staticd_utils/memory_file"

module StaticdUtils

  # Manifest for Staticd releases.
  #
  # A Sitemap consist of an associative array representing each resources of a
  # site release. Each entry consist of the sha1 digest of the resource content
  # and the complete HTTP path this resource must be available to.
  #
  # Example:
  #   sitemap = StaticdUtils::Sitemap.create("/tmp/my_website")
  #   sitemap.to_h
  #   # => {
  #          "058ec3fa8aab4c0ccac27d80fd24f30a8730d3f6"=>"/index.html",
  #          "92136ff551f50188f46486ab80db269eda4dfd4e"=>"/hello/world.html"
  #        }
  class Sitemap

    # Create a sitemap from a directory content.
    #
    # It register each files digest and path inside the sitemap.
    def self.create(path)
      map = {}
      if File.directory?(path)
        Dir.chdir(path) do
          Dir["**/*"].each do |object|
            if File.file?(object)
              sha1 = Digest::SHA1.hexdigest(File.read(object))
              map[sha1] = "/#{object}"
            end
          end
        end
      end
      new(map)
    end

    # Create a sitemap from a YAML string.
    #
    # The YAML string must reflect the sitemap associative array structure.
    #
    # Example:
    #   yaml = "---\n058ec3fa8aab4c0ccac27d80fd24f30a8730d3f6: \"/hi.html\"\n"
    #   sitemap = StaticdUtils::Sitemap.open(yaml)
    def self.open(yaml)
      new(YAML.load(yaml))
    end

    # Create a sitemap from a YAML file.
    #
    # The YAML file must reflect the sitemap associative array structure.
    def self.open_file(path)
      open(File.read(path))
    end

    # Create a sitemap from an associative array.
    #
    # The associative array must have the folowing structure:
    # * Key: the sha1 of the ressource
    # * Value: the HTTP path of the resource
    #
    # Example:
    #   sitemap = Sitemap.new({
    #     058ec3fa8aab4c0ccac27d80fd24f30a8730d3f6: "hi.html"
    #   })
    def initialize(map)
      @map = map
    end

    # View all HTTP path of the sitemap.
    def routes
      @map.map { |sha1, path| path }
    end

    # View all sha1 digest of the sitemap.
    def digests
      @map.map { |sha1, path| sha1 }
    end

    # Iterate over each resources of the sitemap.
    def each_resources
      @map.each { |sha1, path| yield sha1, path }
    end

    def to_h
      @map
    end

    def to_yaml
      @map.to_yaml
    end

    # Export the sitemap to a YAML file stored into memory.
    def to_memory_file
      StaticdUtils::MemoryFile.new(StringIO.new(to_yaml))
    end
  end
end
