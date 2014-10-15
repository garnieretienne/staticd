require "test_helper"
require "staticd/database"

class SiteTest < MiniTest::Unit::TestCase
  include TestHelper

  def setup
    init_fixtures
  end

  def test_it_must_have_an_unique_name
    refute_nil testing_domain.name
    refute DomainName.new(name: "example.org").save
  end

  def test_it_must_belong_to_a_site
    assert_instance_of Site, testing_domain.site
  end
end
