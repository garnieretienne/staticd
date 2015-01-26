# Ensure we require the local version and not one we might have installed already
require File.join([File.dirname(__FILE__),'lib','staticd','version.rb'])

require File.join([File.dirname(__FILE__),'lib', 'gemfile', 'lock'])
gemfile = Gemfile::Lock.new("#{File.dirname(__FILE__)}/Gemfile.lock")

spec = Gem::Specification.new do |s|
  s.name = 'staticd'
  s.version = Staticd::VERSION
  s.license = "MIT"
  s.author = 'Etienne Garnier'
  s.email = 'garnier.etienne@gmail.com'
  s.homepage = 'http://staticd.eggnet.io'
  s.platform = Gem::Platform::RUBY
  s.summary = 'Staticd API and HTTP service'
  s.description =
    'Staticd API and HTTP service to manage and serve staticd content over HTTP'
  s.files =
    Dir["lib/staticd/**/*"] +
    Dir["lib/staticd_utils/**/*"] +
    Dir["lib/rack/**/*"] +
    [
      "lib/staticd.rb",
      "bin/staticd"
    ]
  s.require_paths << 'lib'
  s.bindir = 'bin'
  s.executables << 'staticd'
  %w(
    puma rack sinatra rack-test data_mapper dm-postgres-adapter gli api-auth
    aws-sdk sendfile haml
  ).each do |name|
    s.add_runtime_dependency name, *gemfile.find_requirements(name)
  end
  %w(dm-sqlite-adapter rake byebug foreman).each do |name|
    s.add_development_dependency name, *gemfile.find_requirements(name)
  end
end
