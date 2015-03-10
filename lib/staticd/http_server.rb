require "sendfile"

module Staticd

  # Simple HTTP server Rack app.
  #
  # If the resource is readable from the root folder at the path given by the
  # request, the resource is sent to the client. Otherwise a 404 Not Found HTTP
  # error is sent.
  class HTTPServer

    # Mime types served by the webserver (from NGiNX mime.types file).
    EXT_MIME_TYPE = {
      ".html"    => "text/html",
      ".htm"     => "text/html",
      ".shtml"   => "text/html",
      ".css"     => "text/css",
      ".xml"     => "text/xml",
      ".rss"     => "text/xml",
      ".gif"     => "image/gif",
      ".jpeg"    => "image/jpeg",
      ".jpg"     => "image/jpeg",
      ".js"      => "application/x-javascript",
      ".txt"     => "text/plain",
      ".htc"     => "text/x-component",
      ".mml"     => "text/mathml",
      ".png"     => "image/png",
      ".ico"     => "image/x-icon",
      ".jng"     => "image/x-jng",
      ".wbmp"    => "image/vnd.wap.wbmp",
      ".jar"     => "application/java-archive",
      ".war"     => "application/java-archive",
      ".ear"     => "application/java-archive",
      ".hqx"     => "application/mac-binhex40",
      ".pdf"     => "application/pdf",
      ".cco"     => "application/x-cocoa",
      ".jardiff" => "application/x-java-archive-diff",
      ".jnlp"    => "application/x-java-jnlp-file",
      ".run"     => "application/x-makeself",
      ".pm"      => "application/x-perl",
      ".pl"      => "application/x-perl",
      ".prc"     => "application/x-pilot",
      ".pdb"     => "application/x-pilot",
      ".rar"     => "application/x-rar-compressed",
      ".rpm"     => "application/x-redhat-package-manager",
      ".sea"     => "application/x-sea",
      ".swf"     => "application/x-shockwave-flash",
      ".sit"     => "application/x-stuffit",
      ".tcl"     => "application/x-tcl",
      ".tk"      => "application/x-tcl",
      ".der"     => "application/x-x509-ca-cert",
      ".pem"     => "application/x-x509-ca-cert",
      ".crt"     => "application/x-x509-ca-cert",
      ".xpi"     => "application/x-xpinstall",
      ".zip"     => "application/zip",
      ".deb"     => "application/octet-stream",
      ".bin"     => "application/octet-stream",
      ".exe"     => "application/octet-stream",
      ".dll"     => "application/octet-stream",
      ".dmg"     => "application/octet-stream",
      ".eot"     => "application/octet-stream",
      ".iso"     => "application/octet-stream",
      ".img"     => "application/octet-stream",
      ".msi"     => "application/octet-stream",
      ".msp"     => "application/octet-stream",
      ".msm"     => "application/octet-stream",
      ".mp3"     => "audio/mpeg",
      ".ra"      => "audio/x-realaudio",
      ".mpeg"    => "video/mpeg",
      ".mpg"     => "video/mpeg",
      ".mov"     => "video/quicktime",
      ".flv"     => "video/x-flv",
      ".avi"     => "video/x-msvideo",
      ".wmv"     => "video/x-ms-wmv",
      ".asx"     => "video/x-ms-asf",
      ".asf"     => "video/x-ms-asf",
      ".mng"     => "video/x-mng",
      ".svg"     => "image/svg+xml"
    }

    # Mime type used when no type has been identified.
    DEFAULT_MIME_TYPE = "application/octet-stream"

    def initialize(http_root, access_logger=nil)
      @http_root = http_root
      unless (@access_logger = access_logger)
        @access_logger = Logger.new(STDOUT)
        @access_logger.formatter = proc { |_, _, _, msg| "#{msg}\n"}
      end

      raise "No HTTP root folder provided" unless @http_root
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      @env = env
      req = Rack::Request.new(@env)
      file_path = @http_root + req.path
      res = File.readable?(file_path) ? serve(file_path) : send_404
      log(req, res)
    end

    private

    # Log a request using the "Extended Log File Format".
    # See: http://www.w3.org/TR/WD-logfile.html
    #
    # Use the request.time key setup by the Rack::RequestTime middleware.
    #
    # Version: 1.0
    # Fields: time cs-dns cs-ip date cs-method cs-uri sc-status sc-byte sc-time-taken
    def log(req, res)
      request_stop_time = Time.now
      request_start_time =
        req.env.key?("request.time") ? req.env["request.time"] : nil
      request_completed_time =
        if request_start_time
          (request_stop_time - request_start_time).round(4)
        else
          "-"
        end
      content_length =
        res[1].key?("Content-Length") ? " #{res[1]["Content-Length"]}" : "-"

      log_string = "#{request_stop_time.strftime("%Y-%m-%d %H:%M:%S")}"
      log_string << " #{req.host}"
      log_string << " #{req.env["REMOTE_ADDR"]}"
      log_string << " #{req.env["REQUEST_METHOD"]} #{req.path_info}"
      log_string << " #{res[0]}"
      log_string << content_length
      log_string << " #{request_completed_time}"
      @access_logger.info(log_string)

      res
    end

    # Serve a file.
    #
    # This method will return a Rack compatible response ready to be served to
    # the client. It will use the appropriate method (loading file into memory
    # vs serving file using the sendfile system call) based on availability.
    def serve(file_path)
      @env['rack.hijack?'] ? sendfile(file_path) : send(file_path)
    end

    # Send a file loading it in memory.
    #
    # Method used in the first implementation.
    # Keep it for compatibility purpose when the Rack hijack API is not
    # supported.
    def send(file_path)
      response = Rack::Response.new
      response["Content-Type"] = mime(file_path)
      File.foreach(file_path) { |chunk| response.write(chunk) }
      response.finish
    end

    # Use sendfile system call to send file without loading it into memory.
    #
    # It use the sendfile gem and the rack hijacking api.
    # See: https://github.com/codeslinger/sendfile
    # See: http://blog.phusion.nl/2013/01/23/the-new-rack-socket-hijacking-api/
    def sendfile(file_path)

      response_header = {
        "Content-Type" => mime(file_path),
        "Content-Length" => size(file_path),
        "Connection" => "close"
      }
      response_header["rack.hijack"] = lambda do |io|
        begin
          File.open(file_path) { |file| io.sendfile(file) }
          io.flush
        ensure
          io.close
        end
      end
      [200, response_header]
    end

    def send_404
      res = Rack::Response.new(["Not Found"], 404, {})
      res.finish
    end

    def mime(file_path)
      ext = File.extname(file_path).downcase
      EXT_MIME_TYPE.key?(ext) ? EXT_MIME_TYPE[ext] : DEFAULT_MIME_TYPE
    end

    def size(file_path)
      File.size(file_path).to_s
    end
  end
end
