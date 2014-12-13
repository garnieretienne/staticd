require "test_helper"

class ResourceTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    init_fixtures
    @new_resource = Resource.new
  end

  def test_it_must_have_a_unique_sha1_digest
    assert_model_error @new_resource, :sha1, "Sha1 must not be blank"
    @new_resource.sha1 = sample_resource.sha1
    assert_model_error @new_resource, :sha1, "Sha1 is already taken"
  end

  def test_it_must_have_an_url
    assert_model_error @new_resource, :url, "Url must not be blank"
  end
end
