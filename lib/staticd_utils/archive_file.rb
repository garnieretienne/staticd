module StaticdUtils

  class ArchiveFile

    def initialize(stream)
      @stream = stream
    end

    def read(*args)
      @stream.read *args
    end

    def path
      original_filename
    end

    def original_filename
      "archive.tar.gz"
    end

    def content_type
      "application/x-tar-gz"
    end
  end
end
