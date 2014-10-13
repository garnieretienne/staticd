require "test_helper"
require "json"
require "base64"
require_relative "../api"

class HelloWorldTest < Test::Unit::TestCase
  include TestHelper

  def app
    Sinatra::Application
  end

  def testing_site
    Site.get("test") || Site.create(name: "test")
  end

  def testing_release
    testing_site.releases.first || Release.create(
      site: testing_site,
      tag: "v1",
      url: fixtures_path("files/mywebsite.fr.tar.gz")
    )
  end

  def test_it_should_create_a_new_site
    post "/sites", JSON.generate(name: "testing")
    assert last_response.ok?
    response_data = JSON.parse last_response.body
    assert_equal "testing", response_data["name"]
  end

  def test_it_should_get_a_list_of_all_sites
    site = testing_site
    get "/sites"
    assert last_response.ok?
    response_data = JSON.parse last_response.body
    assert response_data.kind_of?(Array)
    assert !response_data.empty?
    assert response_data.first.kind_of?(String)
  end

  def test_it_should_create_a_new_release_of_a_site
    site = testing_site
    file_path = fixtures_path "files/mywebsite.fr.tar.gz"
    base64 = Base64.encode64 File.read(file_path)
    post "/sites/#{site.name}/releases", JSON.generate(file: base64)
    assert last_response.ok?
    response_data = JSON.parse last_response.body
    assert_equal site.name, response_data["site_name"]
    assert ! response_data["tag"].empty?
    assert ! response_data["url"].empty?
  end

  def test_it_should_list_all_releases_of_a_site
    site = testing_site
    release = testing_release
    get "/sites/#{site.name}/releases"
    assert last_response.ok?
    response_data = JSON.parse last_response.body
    assert response_data.kind_of?(Array)
    assert !response_data.empty?
    assert response_data.first.kind_of?(Integer)
  end
end
