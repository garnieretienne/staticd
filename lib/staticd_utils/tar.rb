require "rubygems/package"
require "digest/sha1"

module StaticdUtils

  # Creation and Extraction of Tarball Stream.
  #
  # Example:
  #  tar = Tar.tar(["/tmp/hello"])
  #  Tar.untar(tar, "/tmp")
  class Tar

    def self.tar(files)
      io = StringIO.new
      tar = Gem::Package::TarWriter.new(io)

      # Gem::Package::TarReader raise an exeption extracting an empty tarball,
      # this add at least one useless file to extract.
      tar.add_file("about", 0644) { |file| file.write("Hello.") }

      files.each do |file|
        content = File.read(file)
        sha1 = Digest::SHA1.hexdigest(content)
        tar.add_file(sha1, 0644) { |entry| entry.write(content) }
      end

      io.rewind
      io
    end

    def self.untar(io, path)
      FileUtils.mkdir_p("#{path}")
      tar = Gem::Package::TarReader.new(io)
      tar.rewind
      tar.each do |entry|
        File.open("#{path}/#{entry.full_name}", "w+") do |file|
          file.write(entry.read)
        end
      end
      tar.close
    end
  end
end
