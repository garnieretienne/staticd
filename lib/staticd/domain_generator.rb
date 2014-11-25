module Staticd

  # Domain name generator.
  #
  # This class can be used to generate random words of various length.
  # Options:
  # * length: the length of the random word
  # * suffix: a suffix to append to the random world (default is none)
  #
  # Example:
  #   DomainGenerator.new(length: 2, suffix: ".domain.tld")
  #   # => rb.domain.tld
  #
  # A block can be used to validate the generated domain. It must return true
  # to validate the domain, otherwise a new one is proposed. This feature can
  # be used to validate the domain against certain rules.
  #
  # Example:
  #   DomainGenerator.new(suffix: ".domain.tld") do |generated_domain|
  #     ["admin", "www"].include?(generated_domain)
  #   end
  class DomainGenerator

    def self.new(options={})
      if block_given?
        until domain = generate(options)
          yield domain
        end
        domain
      else
        generate(options)
      end
    end

    def self.generate(options={})
      length = options[:length] || 6
      suffix = options[:suffix] || ""
      random = ("a".."z").to_a.shuffle[0, length].join
      random + suffix
    end
  end
end
