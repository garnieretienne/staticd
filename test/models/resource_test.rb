require "test_helper"

class ResourceTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    init_fixtures
  end

  def test_it_must_have_path_through_routes
    refute_nil sample_resource.routes.first.path
  end

  def test_it_must_have_an_url
    refute_nil sample_resource.url
  end

  def test_it_must_belong_to_at_least_one_release
    assert_instance_of Release, sample_resource.releases.first
  end
end
