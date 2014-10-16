require "test_helper"
require "json"
require "base64"
require "staticd/api"

class APITest < MiniTest::Test
  include TestHelper

  def app
    Staticd::API
  end

  def setup
    init_fixtures
  end

  def test_it_should_create_a_new_site
    post "/sites", JSON.generate(name: "testing")
    assert last_response.ok?
    response_data = JSON.parse last_response.body
    assert_equal "testing", response_data["name"]
  end

  def test_it_should_return_an_error_creating_a_bad_new_site
    post "/sites"
    refute last_response.ok?
    response_data = JSON.parse last_response.body
    refute response_data["error"].empty?
  end

  def test_it_should_get_a_list_of_all_sites
    get "/sites"
    assert last_response.ok?
    response_data = JSON.parse last_response.body
    assert response_data.kind_of?(Array)
    assert !response_data.empty?
    assert response_data.first.kind_of?(String)
  end

  def test_it_should_create_a_new_release_of_a_site
    file_path = fixtures_path "files/mywebsite.fr.tar.gz"
    base64 = Base64.encode64 File.read(file_path)
    post "/sites/#{testing_site.name}/releases", JSON.generate(file: base64)
    assert last_response.ok?
    response_data = JSON.parse last_response.body
    assert_equal testing_site.name, response_data["site_name"]
    refute response_data["tag"].empty?
    refute response_data["url"].empty?
  end

  def test_it_should_return_an_error_creating_a_new_release_of_a_unknown_site
    post "/sites/unknown_site/releases"
    refute last_response.ok?
    response_data = JSON.parse last_response.body
    refute response_data["error"].empty?
  end

  def test_it_should_return_an_error_crating_a_bad_new_release_of_a_site
    post "/sites/#{testing_site.name}/releases"
    refute last_response.ok?
    response_data = JSON.parse last_response.body
    refute response_data["error"].empty?
  end

  def test_it_should_list_all_releases_of_a_site
    get "/sites/#{testing_site.name}/releases"
    assert last_response.ok?
    response_data = JSON.parse last_response.body
    assert response_data.kind_of?(Array)
    refute response_data.empty?
    assert response_data.first.kind_of?(String)
  end

  def test_it_should_return_an_error_listing_all_releases_of_an_unknown_site
    get "/sites/unknown_site/releases"
    refute last_response.ok?
    response_data = JSON.parse last_response.body
    refute response_data["error"].empty?
  end

  def test_it_should_add_new_domain_name_to_a_site
    post "/sites/#{testing_site.name}/domain_names",
      JSON.generate(name: "hi.com")
    assert last_response.ok?
    response_data = JSON.parse last_response.body
    assert_equal "hi.com", response_data["name"]
    assert_equal testing_site.name, response_data["site_name"]
  end

  def test_it_should_return_an_error_adding_a_new_domain_to_an_unknown_site
    post "/sites/unknown/domain_names"
    refute last_response.ok?
    response_data = JSON.parse last_response.body
    refute response_data["error"].empty?
  end

  def test_it_should_return_an_error_adding_a_bad_new_domain_to_a_site
    post "/sites/#{testing_site.name}/domain_names"
    refute last_response.ok?
    response_data = JSON.parse last_response.body
    refute response_data["error"].empty?
  end
end
