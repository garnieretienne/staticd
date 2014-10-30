require "json"

module Staticd
  class JSONResponse
    def self.send(type, content=nil)
      case type
      when :success
        @status = 200
        @body = content
      when :success_no_content
        @status = 204
      when :error
        @status = 403
        @body = {error: content}
      else
        @status = 500
        @body = {error: "Something went wrong"}
      end
      json_body = @body ? JSON.generate(@body) : nil
      [@status, json_body]
    end
  end
end
