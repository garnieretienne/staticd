require "json"

module Staticd
  class JSONRequest
    def self.parse(body)
      body.empty? ? {} : JSON.parse(body)
    end
  end
end
