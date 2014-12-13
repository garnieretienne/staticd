require "test_helper"

class ReleaseTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    init_fixtures
    @new_release = Release.new
  end

  def test_it_must_have_a_tag
    assert_model_error @new_release, :tag, "Tag must not be blank"
  end

  def test_it_must_belong_to_a_site
    assert_model_error @new_release, :site_name, "Site name must not be blank"
  end
end
