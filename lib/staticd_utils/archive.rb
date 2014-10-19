require "rubygems/package"
require "zlib"
require "base64"
require "open-uri"

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

    def self.create(directory_path)

      tar_stream = StringIO.new
      tar = Gem::Package::TarWriter.new(tar_stream)
      Dir["#{directory_path}/**/*"].each do |entry|
        entry_path = entry.sub(directory_path, "")
        if File.directory? entry
          tar.mkdir entry_path, 0755
        else
          tar.add_file(entry_path, 0644) do |file|
            file.write File.read(entry)
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
  end
end
