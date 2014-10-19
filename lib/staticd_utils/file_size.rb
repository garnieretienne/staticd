module StaticdUtils
  class FileSize

    def initialize(size)
      @size = size
    end

    # Source: https://www.ruby-forum.com/topic/126876#565940
    def to_s
      units = %w{B KB MB GB TB}
      e = (Math.log(@size)/Math.log(1024)).floor
      s = "%.3f" % (@size.to_f / 1024**e).to_i
      s.sub(/\.?0*$/, units[e])
    end
  end
end
