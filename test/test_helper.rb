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
    sample_site
    sample_release
    sample_domain
    sample_resource
    return sample_site
  end

  def check_testing_database
    unless @database_initialized
      init_database(:test, "sqlite::memory:")
      @database_initialized = true
    end
  end

  def sample_site
    check_testing_database
    @sample_site ||=
      Staticd::Model::Site.get("test") ||
      Staticd::Model::Site.create(name: "test")
  end

  def sample_release
    check_testing_database
    @sample_release ||=
      Staticd::Model::Release.get(site_name: sample_site.name, tag: "v1") ||
      Staticd::Model::Release.create(
        site: sample_site,
        tag: "v1"
      )
  end

  def sample_resource
    check_testing_database
    return @sample_resource unless @sample_resource.nil?

    existing_resource = Staticd::Model::Resource.get(
      url: fixtures_path("files/mywebsite.fr.tar.gz")
    )
    unless existing_resource.nil?
      @sample_resource = existing_resource
    else
      new_resource = Staticd::Model::Resource.create(
        url: fixtures_path("files/mywebsite.fr.tar.gz")
      )
      release_map = Staticd::Model::ReleaseMap.create(
        resource_id: new_resource.id,
        release_id: sample_release.id,
        path: "/index.html"
      )
      @sample_resource = new_resource
    end
    return @existing_resource
  end

  def sample_domain
    check_testing_database
    @sample_domain ||=
      Staticd::Model::DomainName.get(
        site_name: sample_site.name,
        name: "example.org"
      ) ||
      Staticd::Model::DomainName.create(site: sample_site, name: "example.org")
  end
end
