require "test_helper"

class SiteTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    init_fixtures
  end

  def test_it_must_have_an_unique_name
    assert !sample_site.name.nil?
    assert !Staticd::Model::Site.new(name: "test").save
  end

  def test_it_can_have_releases
    assert_respond_to sample_site, :releases
    assert_kind_of Enumerable, sample_site.releases
  end

  def test_it_can_have_domain_names
    assert_respond_to sample_site, :domain_names
    assert_kind_of Enumerable, sample_site.domain_names
  end
end
