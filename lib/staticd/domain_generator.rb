module Staticd
  class DomainGenerator

    def self.new(word)
      wildcard = ENV["STATICD_WILDCARD_DOMAIN"] || "localhost"
      return "#{word}.#{wildcard}"
    end
  end
end
