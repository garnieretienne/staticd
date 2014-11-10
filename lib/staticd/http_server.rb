module Staticd
  class HTTPServer

    def initialize(http_root)
      @http_root = http_root
    end

    def call(env)
      req = Rack::Request.new env
      file_path = @http_root + req.path
      send file_path
    end

    private

    def send(file)
      if File.readable? file
        res = Rack::Response.new
        File.foreach(file){|chunk| res.write chunk}
        res.finish
      else
        send_404
      end
    end

    def send_404
      res = Rack::Response.new ["Not Found"], 404, {}
      res.finish
    end
  end
end
