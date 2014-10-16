require "json"

module Staticd
  class JSONResponse
    def self.send(type, content)
      case type
      when :success then
        @status = 200
        @body = content
      when :error
        @status = 403
        @body = {error: content}
      else
        @status = 500
        @body = {error: "Something went wrong"}
      end
      [@status, JSON.generate(@body)]
    end
  end
end
