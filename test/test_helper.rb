ENV['RACK_ENV'] = "test"

require "minitest/autorun"
require "rack/test"
require "byebug"
require "staticd/database"

module TestHelper
  include Rack::Test::Methods
  include Staticd::Database

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

  def check_testing_database
    unless @database_initialized
      init_database(:test, "sqlite::memory:")
      @database_initialized = true
    end
  end

  def testing_site
    check_testing_database
    @testing_site ||=
      Staticd::Model::Site.get("test") ||
      Staticd::Model::Site.create(name: "test")
  end

  def testing_release
    check_testing_database
    @testing_release ||=
      Staticd::Model::Release.get(site_name: testing_site.name, tag: "v1") ||
      Staticd::Model::Release.create(
        site: testing_site,
        tag: "v1",
        url: fixtures_path("files/mywebsite.fr.tar.gz")
      )
  end

  def testing_domain
    check_testing_database
    @testing_domain ||=
      Staticd::Model::DomainName.get(
        site_name: testing_site.name,
        name: "example.org"
      ) ||
      Staticd::Model::DomainName.create(site: testing_site, name: "example.org")
  end
end
