require "json"

module Staticd

  # Simple HTTP response constructor for JSON content.
  #
  # Example:
  #   response = JSONResponse.send(:success, {foo: :bar})
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
        @body = {error: "Something went wrong on our side."}
      end
      json_body = @body ? JSON.generate(@body) : nil
      [@status, json_body]
    end
  end
end
