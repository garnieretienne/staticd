module StaticdUtils

  # Make an IO object behave like File objects.
  #
  # Example:
  #   io = StringIO.new("Content")
  #   file = MemoryFile.new(io)
  #   file.read
  #   # => "Content"
  #   file.path
  #   # => "memory_file"
  #   file.content_type
  #   # => "application/octet-stream"
  class MemoryFile

    def initialize(stream)
      @stream = stream
    end

    def read(*args)
      @stream.read(*args)
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
