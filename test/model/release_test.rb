require "test_helper"

class ReleaseTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    init_fixtures
  end

  def test_it_must_have_a_tag
    refute_nil testing_release.tag
  end

  def test_it_must_have_an_url
    refute_nil testing_release.url
  end

  def test_it_must_belong_to_a_site
    assert_instance_of Staticd::Model::Site, testing_release.site
  end
end
