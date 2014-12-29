require "test_helper"
require "base64"
require "json"
require "staticd/api"

class APITest < Minitest::Unit::TestCase
  include TestHelper

  def app
    Staticd::API.new(domain: Staticd::Config[:domain])
  end

  def setup
    init_fixtures
  end

  def test_it_should_create_a_new_site
    post_json "/sites", name: "testing"
    assert last_response.ok?
    response_data = JSON.parse(last_response.body)
    assert_equal "testing", response_data["name"]
  end

  def test_it_should_return_an_error_creating_a_bad_new_site
    post_json "/sites"
    refute last_response.ok?
    response_data = JSON.parse(last_response.body)
    refute response_data["error"].empty?
  end

  def test_it_should_delete_a_site_and_all_attached_resources
    delete "/sites/#{sample_site}"
    assert_equal 204, last_response.status
    assert last_response.body.empty?
  end

  def test_it_should_return_an_error_deleting_an_unknown_site
    delete "/sites/unknown_site"
    assert_equal 403, last_response.status
    response_data = JSON.parse(last_response.body)
    refute response_data["error"].empty?
  end

  def test_it_should_get_a_list_of_all_sites
    get "/sites"
    assert last_response.ok?
    response_data = JSON.parse(last_response.body)
    assert response_data.kind_of?(Array)
    refute response_data.empty?
    assert response_data.first.kind_of?(Hash)
  end

  def test_it_should_create_a_new_release_of_a_site
    file_path = fixtures_path("files/mywebsite.tar")
    sitemap_path = fixtures_path("files/sitemap.yml")
    post(
      "/sites/#{sample_site.name}/releases",
      file: Rack::Test::UploadedFile.new(file_path, "application/x-tar-gz"),
      sitemap: Rack::Test::UploadedFile.new(sitemap_path, "text/yaml")
    )
    assert last_response.ok?
    response_data = JSON.parse(last_response.body)
    assert_equal sample_site.name, response_data["site_name"]
    refute response_data["tag"].empty?
  end

  def test_it_should_return_an_error_creating_a_new_release_of_a_unknown_site
    post "/sites/unknown_site/releases"
    refute last_response.ok?
    response_data = JSON.parse(last_response.body)
    refute response_data["error"].empty?
  end

  def test_it_should_return_an_error_creating_a_bad_new_release_of_a_site
    post "/sites/#{sample_site.name}/releases"
    refute last_response.ok?
    response_data = JSON.parse(last_response.body)
    refute response_data["error"].empty?
  end

  def test_it_should_list_all_releases_of_a_site
    get "/sites/#{sample_site.name}/releases"
    assert last_response.ok?
    response_data = JSON.parse(last_response.body)
    assert response_data.kind_of?(Array)
    refute response_data.empty?
    assert response_data.first.kind_of?(Hash)
  end

  def test_it_should_return_an_error_listing_all_releases_of_an_unknown_site
    get "/sites/unknown_site/releases"
    refute last_response.ok?
    response_data = JSON.parse(last_response.body)
    refute response_data["error"].empty?
  end

  def test_it_should_add_new_domain_name_to_a_site
    post_json "/sites/#{sample_site}/domain_names", name: "hi.com"
    assert last_response.ok?
    response_data = JSON.parse(last_response.body)
    assert_equal "hi.com", response_data["name"]
    assert_equal sample_site.name, response_data["site_name"]
  end

  def test_it_should_return_an_error_adding_a_new_domain_to_an_unknown_site
    post_json "/sites/unknown/domain_names"
    refute last_response.ok?
    response_data = JSON.parse(last_response.body)
    refute response_data["error"].empty?
  end

  def test_it_should_remove_a_domain_from_a_site
    delete "/sites/#{sample_site}/domain_names/#{sample_domain}"
    assert_equal 204, last_response.status
    assert last_response.body.empty?
  end

  def it_should_return_an_error_removing_a_domain_to_an_unknown_site
    delete "/sites/unknown/domain_names/#{sample_domain}"
    assert_equal 403, last_response.status
    response_data = JSON.parse(last_response.body)
    refute response_data["error"].empty?
  end

  def it_should_return_an_error_removing_an_unknown_domain_from_a_site
    delete "/sites/#{sample_site}/domain_names/unknown.com"
    assert_equal 403, last_response.status
    response_data = JSON.parse(last_response.body)
    refute response_data["error"].empty?
  end

  def test_it_should_return_an_error_adding_a_bad_new_domain_to_a_site
    post_json "/sites/#{sample_site}/domain_names"
    refute last_response.ok?
    response_data = JSON.parse(last_response.body)
    refute response_data["error"].empty?
  end

  def test_it_should_list_all_domain_names_attached_to_a_site
    get "/sites/#{sample_site}/domain_names"
    assert last_response.ok?
    response_data = JSON.parse(last_response.body)
    assert response_data.kind_of?(Array)
    refute response_data.empty?
    assert response_data.first.kind_of?(Hash)
  end

  def test_it_should_return_an_error_listing_all_domains_of_an_unknown_site
    get "/sites/unknown_site/domain_names"
    refute last_response.ok?
    response_data = JSON.parse(last_response.body)
    refute response_data["error"].empty?
  end

  def test_it_should_return_a_list_of_unknown_resources_when_provided_with_sitemap
    post_json "/resources/get_cached", sample_resource.sha1 => "/fake/path",
      "unknown_sha1" => "/another/fake/path"
    assert last_response.ok?
    response_data = JSON.parse(last_response.body)
    assert_equal({"unknown_sha1" => "/another/fake/path"}, response_data)
  end
end
