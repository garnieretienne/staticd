require "sendfile"

module Staticd
  class HTTPServer

    EXT_MIME_TYPE = {
      ".html" => "text/html",
      ".css"  => "text/css",
      ".js"   => "application/javascript",
      ".jpg"  => "image/jpeg",
      ".png"  => "image/png",
      ".gif"  => "image/gif",
      ".avi"  => "video/avi"
    }

    DEFAULT_MIME_TYPE = 'application/octet-stream'

    def initialize(http_root)
      @http_root = http_root
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @env = env
      req = Rack::Request.new @env
      file_path = @http_root + req.path

      if File.readable? file_path
        sendfile file_path
      else
        send_404
      end
    end

    private

    def send(file_path)
      response = Rack::Response.new
      response["Content-Type"] = mime file_path
      File.foreach(file_path){|chunk| response.write chunk}
      response.finish
    end

    # Use sendfile system call to send file without loading it into memory.
    #
    # It use the sendfile gem and the rack hijacking api.
    # see: https://github.com/codeslinger/sendfile
    # see: http://blog.phusion.nl/2013/01/23/the-new-rack-socket-hijacking-api/
    def sendfile(file_path)
      @env['rack.hijack'].call
      io = @env['rack.hijack_io']

      # Rescue: Do not raise a Errno::EPIPE: Broken pipe - sendfile if
      # transfert is canceled by the client
      begin
        io.write("HTTP/1.1 200 OK\r\n")
        io.write("Connection: close\r\n")
        io.write("Content-Type: #{mime(file_path)}\r\n")
        io.write("Content-Length: #{size(file_path)}\r\n")
        io.write("\r\n")
        File.open(file_path){|file| io.sendfile file}
        io.flush
      rescue
        true
      ensure
        io.close
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

    def size(file)
      File.size(file).to_s
    end
  end
end
