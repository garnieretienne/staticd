module StaticdUtils

  class MemoryFile

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
      "memory_file"
    end

    def content_type
      "application/octet-stream"
    end
  end
end
