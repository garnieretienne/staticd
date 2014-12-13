require "test_helper"

class DomainNameTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    init_fixtures
    @new_domain = DomainName.new
  end

  def test_it_must_have_an_unique_name
    assert_model_error @new_domain, :name, "Name must not be blank"
    @new_domain.name = sample_domain.name
    assert_model_error @new_domain, :name, "Name is already taken"
  end

  def test_it_must_belong_to_a_site
    @new_domain = DomainName.new(name: "#{Time.now.to_i}")
    assert_model_error @new_domain, :site_name, "Site name must not be blank"
  end
end
