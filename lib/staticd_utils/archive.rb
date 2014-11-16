require "rubygems/package"
require "zlib"
require "base64"
require "open-uri"
require "staticd_utils/archive_file"
require 'digest/sha1'

module StaticdUtils
  class Archive

    attr_reader :stream

    def initialize(stream)
      @stream = stream
    end

    def close
      @stream.close unless @stream.closed?
    end

    def self.open_file(url)
      self.new open(url)
    end

    def self.open_base64(base64)
      self.new StringIO.new(Base64.decode64(base64))
    end

    def self.create(directory_path, manifest=nil)
      tar_stream = StringIO.new
      tar = Gem::Package::TarWriter.new(tar_stream)
      Dir.chdir(directory_path) do
        manifest ||= Dir["**/*"].select{|entry| File.file? entry}
        manifest.each do |entry|
          content = File.read(entry)
          sha1 = Digest::SHA1.hexdigest(content)
          tar.add_file(sha1, 0644) do |file|
            file.write content
          end
        end
      end
      tar_stream.rewind

      gz_stream = StringIO.new
      gzip = Zlib::GzipWriter.new(gz_stream)
      gzip.write tar_stream.read
      gzip.finish
      tar_stream.close

      gz_stream.rewind
      self.new gz_stream
    end

    def to_base64
      return false if @stream.closed?
      base64 = Base64.encode64 @stream.read
      self.close
      base64
    end

    def to_file(path)
      return false if @stream.closed?
      File.open(path, 'w') do |file|
        file.write @stream.read
      end
      self.close
      path
    end

    def to_archive_file
      StaticdUtils::ArchiveFile.new @stream
    end

    def extract(path)
      return false if @stream.closed?
      FileUtils.mkdir_p "#{path}"
      gzip = Zlib::GzipReader.new(@stream)
      gzip.rewind
      tar = Gem::Package::TarReader.new gzip
      tar.rewind
      tar.each do |entry|
        if entry.directory?
          FileUtils.mkdir_p "#{path}/#{entry.full_name}"
        elsif entry.file?
          File.open("#{path}/#{entry.full_name}", "w") do |file|
            file.write entry.read
          end
        end
      end
      gzip.close
      tar.close
      self.close
      path
    end

    def size
      @stream.size
    end
  end
end
