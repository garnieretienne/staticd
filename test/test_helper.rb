ENV["RACK_ENV"] = "test"

require "minitest/autorun"
require "rack/test"
require "byebug"
require "staticd/database"
require 'staticd/config'

module TestHelper
  include Rack::Test::Methods
  include Staticd::Database
  include Staticd::Models

  def root_path
    File.expand_path(File.dirname(__FILE__))
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
      init_database(:test, app_config.database)
      @database_initialized = true
    end
  end

  def app_config
    return @app_config if @app_config

    @app_config = Staticd::Config.parse(
      "#{File.dirname(__FILE__)}/../etc/staticd.yml.erb", :test
    )
    @app_config.to_env!
    @app_config
  end

  def sample_site
    check_testing_database
    @sample_site ||= Site.get("test") || Site.create(name: "test")
  end

  def sample_release
    check_testing_database
    @sample_release ||=
      Release.get(site_name: sample_site.name, tag: "v1") ||
      Release.create(site: sample_site, tag: "v1")
  end

  def sample_resource
    check_testing_database
    return @sample_resource unless @sample_resource.nil?

    existing_resource = Resource.get("058ec3fa8aab4c0ccac27d80fd24f30a8730d3f6")
    return @sample_resource = existing_resource if existing_resource

    new_resource = Resource.create(
      sha1: "058ec3fa8aab4c0ccac27d80fd24f30a8730d3f6",
      url: fixtures_path("sites/hello_world/index.html")
    )
    route = Route.create(
      resource_sha1: new_resource.sha1,
      release_id: sample_release.id,
      path: "/index.html"
    )
    @sample_resource = new_resource
  end

  def sample_domain
    check_testing_database
    @sample_domain ||=
      DomainName.get(site_name: sample_site.name, name: "example.org") ||
      DomainName.create(site: sample_site, name: "example.org")
  end

  def post_json(uri, json={})
    post uri, JSON.generate(json), {"CONTENT_TYPE" => "application/json"}
  end

  def assert_model_error(object, property, message)
    refute object.valid?,
      "'#{object}' has no error and is valid."
    assert object.errors.key?(property),
      "Error list '#{object.errors.keys}' is missing '#{property}' property."
    assert object.errors[property].include?(message),
      "Error messages list '#{object.errors[property]}' doesn't include " +
      "'#{message}'."
  end
end
