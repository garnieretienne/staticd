require "rubygems/package"
require "zlib"
require "base64"
require "digest/sha1"
require "open-uri"
require "staticd_utils/memory_file"

module StaticdUtils

  class Archive
    attr_reader :stream

    def self.open_file(url)
      new(open(url))
    end

    # Create an archive from a folder.
    #
    # Can include a manifest as an array of files full path (from directory path
    # as root).
    #
    # Example:
    #   StaticdUtils::Archive.create("/tmp/my_site", ["/index.html"])
    #   # Only the /tmp/my_site/index.html file will be included into
    #     the archive.
    def self.create(directory_path, manifest=nil)
      tar_stream = StringIO.new
      tar = Gem::Package::TarWriter.new(tar_stream)
      Dir.chdir(directory_path) do
        manifest ||=
          Dir["**/*"].
            select { |f| File.file?(f) }.
            map { |f| "/#{f}" }

        # Gem::Package::TarReader raise an exeption extracting an empty tarball,
        # this add at least one useless file to extract.
        tar.add_file("about", 0644) do |file|
          file.write("Hello.")
        end

        manifest.each do |entry|
          content = File.read(".#{entry}")
          sha1 = Digest::SHA1.hexdigest(content)
          tar.add_file(sha1, 0644) do |file|
            file.write(content)
          end
        end
      end
      tar_stream.rewind

      gz_stream = StringIO.new
      gzip = Zlib::GzipWriter.new(gz_stream)
      gzip.write(tar_stream.read)
      gzip.finish
      tar_stream.close

      gz_stream.rewind
      new(gz_stream)
    end

    def initialize(stream)
      @stream = stream
    end

    def open
      Dir.mktmpdir do |tmp|
        Dir.chdir(tmp) do
          extract(tmp)
          yield tmp
        end
      end
    end

    def close
      @stream.close unless @stream.closed?
    end

    def extract(path)
      return false if @stream.closed?

      FileUtils.mkdir_p("#{path}")

      gzip = Zlib::GzipReader.new(@stream)
      gzip.rewind

      tar = Gem::Package::TarReader.new(gzip)
      tar.rewind
      tar.each do |entry|
        File.open("#{path}/#{entry.full_name}", "w+") do |file|
          file.write(entry.read)
        end
      end
      gzip.close
      tar.close
      close
      path
    end

    def size
      @stream.size
    end

    def to_file(path)
      return false if @stream.closed?

      File.open(path, 'w') { |file| file.write(@stream.read) }
      self.close
      path
    end

    def to_memory_file
      StaticdUtils::MemoryFile.new(@stream)
    end
  end
end
