require "test_helper"

class DomainNameTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    init_fixtures
  end

  def test_it_must_have_an_unique_name
    refute_nil sample_domain.name
    refute Staticd::Model::DomainName.new(name: "example.org").save
  end

  def test_it_must_belong_to_a_site
    assert_instance_of Staticd::Model::Site, sample_domain.site
  end
end
