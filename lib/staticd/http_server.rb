module Staticd
  class HTTPServer

    EXT_MIME_TYPE = {
      ".html" => "text/html",
      ".css"  => "text/css",
      ".js"   => "application/javascript",
      ".jpg"  => "image/jpeg",
      ".png"  => "image/png",
      ".gif"  => "image/gif"
    }

    DEFAULT_MIME_TYPE = 'application/octet-stream'

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
        res["Content-Type"] = mime file
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

    def mime(file)
      ext = File.extname(file).downcase
      EXT_MIME_TYPE.has_key?(ext) ? EXT_MIME_TYPE[ext] : DEFAULT_MIME_TYPE
    end
  end
end
