require "json"

module Staticd

  # Simple JSON body parser for HTTP request.
  #
  # Example:
  #   hash = JSONRequest.parse(request_body)
  class JSONRequest

    def self.parse(body)
      body.empty? ? {} : JSON.parse(body)
    end
  end
end
