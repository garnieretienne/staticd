require "test_helper"

class ReleaseTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    init_fixtures
  end

  def test_it_must_have_a_tag
    refute_nil sample_release.tag
  end

  def test_it_must_have_resources
    assert_respond_to sample_release, :resources
    assert_kind_of Enumerable, sample_release.resources
  end

  def test_it_must_belong_to_a_site
    assert_instance_of Site, sample_release.site
  end
end
