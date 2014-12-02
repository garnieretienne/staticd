require "zlib"
require "base64"
require "open-uri"
require "staticd_utils/memory_file"
require "staticd_utils/tar"

module StaticdUtils

  # Manage Staticd archives.
  #
  # This class can manage the archives used as transport package to transfer
  # files beetween Staticd client and Staticd API.
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
      files =
        if manifest
          manifest.map { |entry| directory_path + entry }
        else
          Dir["#{directory_path}/**/*"].select { |f| File.file?(f) }
        end
      new(Tar.tar(files))
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

      Tar.untar(@stream, path)
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
