module Gemfile

  # Class to analyze the content of a Gemfile.lock file
  class Lock

    def initialize(path)
      @content = File.read path
    end

    # Find the requirements of the gem used by bundler
    def find_requirements(gem_name)
      pattern = /    #{gem_name} \((.*)\)/
      begin
        @content.scan(pattern).first.first.split(", ")
      rescue
        []
      end
    end
  end
end
