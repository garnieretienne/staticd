# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','staticdctl','version.rb'])

require File.join([File.dirname(__FILE__),'lib', 'gemfile', 'lock'])
gemfile = Gemfile::Lock.new("#{File.dirname(__FILE__)}/Gemfile.lock")

spec = Gem::Specification.new do |s|
  s.name = 'staticdctl'
  s.version = Staticdctl::VERSION
  s.license = "MIT"
  s.author = 'Etienne Garnier'
  s.email = 'garnier.etienne@gmail.com'
  s.homepage = 'http://staticd.eggnet.io'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Staticd CLI Client'
  s.description = 'CLI Client for the Staticd API service'
  s.files = Dir["lib/staticdctl/**/*"] + Dir["lib/staticd_utils/**/*"] + [
    "lib/staticdctl.rb",
    "bin/staticdctl"
  ]
  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'staticdctl'
  %w(rake gli rest_client api-auth).each do |name|
    s.add_runtime_dependency name, *gemfile.find_requirements(name)
  end
end
