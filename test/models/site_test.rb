require "test_helper"
require_relative "../../models/site"

class SiteTest < Test::Unit::TestCase
  include TestHelper

  def test_it_should_have_an_unique_name
    my_site = Site.new name: "my_shiny_website"
    assert_equal "my_shiny_website", my_site.name
  end
end
