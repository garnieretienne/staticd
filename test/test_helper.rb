ENV['RACK_ENV'] = "test"

require "minitest/autorun"
require "rack/test"
require "byebug"

module TestHelper
  include Rack::Test::Methods

  def root_path
    File.expand_path File.dirname(__FILE__)
  end

  def fixtures_path(fixture)
    "#{root_path}/fixtures/#{fixture}"
  end

  def init_fixtures
    testing_site
    testing_release
    testing_domain
    return testing_site
  end

  def testing_site
    @testing_site ||= Site.get("test") || Site.create(name: "test")
  end

  def testing_release
    @testing_release ||= Release.get(site_name: testing_site.name, tag: "v1") ||
        Release.create(
          site: testing_site,
          tag: "v1",
          url: fixtures_path("files/mywebsite.fr.tar.gz")
        )
  end

  def testing_domain
    @testing_domain ||= DomainName.get(
      site_name: testing_site.name,
      name: "example.org"
    ) ||
    DomainName.create(site: testing_site, name: "example.org")
  end
end
