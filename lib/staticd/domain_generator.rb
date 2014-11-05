module Staticd
  class DomainGenerator

    def self.new(word, domain)
      return "#{word}.#{domain}"
    end
  end
end
