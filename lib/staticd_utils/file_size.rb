module StaticdUtils

  # Class to convert file size in octect to human readable size.
  #
  # Example:
  #   Staticd::FileSize.new(1000).to_s
  #   # => "1KB"
  class FileSize

    def initialize(size)
      @size = size
    end

    def to_s
      units = %w(B KB MB GB TB)
      base = 1000
      return "#{@size}#{units[0]}" if @size < base

      exponent = (Math.log(@size) / Math.log(base)).to_i
      exponent = units.size - 1 if exponent > units.size - 1

      human_size = @size / base**exponent
      "#{human_size}#{units[exponent]}"
    end
  end
end
