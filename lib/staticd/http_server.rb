require "sendfile"

module Staticd
  class HTTPServer

    # Mime types served by the webserver
    # Take from NGiNX mime.types file.
    DEFAULT_MIME_TYPE = 'application/octet-stream'
    EXT_MIME_TYPE = {
      ".html"    => "text/html"
      ".html"    => "text/htm"
      ".html"    => "text/shtml"
      ".css"     => "text/css"
      ".xml"     => "text/xml"
      ".rss"     => "text/xml"
      ".gif"     => "image/gif"
      ".jpeg"    => "image/jpeg"
      ".jpg"     => "image/jpeg"
      ".js"      => "application/x-javascript"
      ".txt"     => "text/plain"
      ".htc"     => "text/x-component"
      ".mml"     => "text/mathml"
      ".png"     => "image/png"
      ".ico"     => "image/x-icon"
      ".jng"     => "image/x-jng"
      ".wbmp"    => "image/vnd.wap.wbmp"
      ".jar"     => "application/java-archive"
      ".war"     => "application/java-archive"
      ".ear"     => "application/java-archive"
      ".hqx"     => "application/mac-binhex40"
      ".pdf"     => "application/pdf"
      ".cco"     => "application/x-cocoa"
      ".jardiff" => "application/x-java-archive-diff"
      ".jnlp"    => "application/x-java-jnlp-file"
      ".run"     => "application/x-makeself"
      ".pm"      => "application/x-perl"
      ".pl"      => "application/x-perl"
      ".prc"     => "application/x-pilot"
      ".pdb"     => "application/x-pilot"
      ".rar"     => "application/x-rar-compressed"
      ".rpm"     => "application/x-redhat-package-manager"
      ".sea"     => "application/x-sea"
      ".swf"     => "application/x-shockwave-flash"
      ".sit"     => "application/x-stuffit"
      ".tcl"     => "application/x-tcl"
      ".tk"      => "application/x-tcl"
      ".der"     => "application/x-x509-ca-cert"
      ".pem"     => "application/x-x509-ca-cert"
      ".crt"     => "application/x-x509-ca-cert"
      ".xpi"     => "application/x-xpinstall"
      ".zip"     => "application/zip"
      ".deb"     => "application/octet-stream"
      ".bin"     => "application/octet-stream"
      ".exe"     => "application/octet-stream"
      ".dll"     => "application/octet-stream"
      ".dmg"     => "application/octet-stream"
      ".eot"     => "application/octet-stream"
      ".iso"     => "application/octet-stream"
      ".img"     => "application/octet-stream"
      ".msi"     => "application/octet-stream"
      ".msp"     => "application/octet-stream"
      ".msm"     => "application/octet-stream"
      ".mp3"     => "audio/mpeg"
      ".ra"      => "audio/x-realaudio"
      ".mpeg"    => "video/mpeg"
      ".mpg"     => "video/mpeg"
      ".mov"     => "video/quicktime"
      ".flv"     => "video/x-flv"
      ".avi"     => "video/x-msvideo"
      ".wmv"     => "video/x-ms-wmv"
      ".asx"     => "video/x-ms-asf"
      ".asf"     => "video/x-ms-asf"
      ".mng"     => "video/x-mng"
    }

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
