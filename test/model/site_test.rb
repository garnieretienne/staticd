require "test_helper"
require "staticd/database"

class SiteTest < MiniTest::Test
  include TestHelper

  def setup
    init_fixtures
  end

  def test_it_must_have_an_unique_name
    assert !testing_site.name.nil?
    assert !Staticd::Model::Site.new(name: "test").save
  end

  def test_it_can_have_releases
    assert_respond_to testing_site, :releases
    assert_kind_of Enumerable, testing_site.releases
  end

  def test_it_can_have_domain_names
    assert_respond_to testing_site, :domain_names
    assert_kind_of Enumerable, testing_site.domain_names
  end
end
