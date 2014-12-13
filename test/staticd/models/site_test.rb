require "test_helper"

class SiteTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    init_fixtures
    @new_site = Site.new
  end

  def test_it_must_have_an_unique_name
    assert_model_error @new_site, :name, "Name must not be blank"
    @new_site.name = sample_site.name
    assert_model_error @new_site, :name, "Name is already taken"
  end
end
