require "test_helper"
require "staticd_utils/sitemap"
require 'yaml'

class SitemapTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    @hello_world_map = {
      "92136ff551f50188f46486ab80db269eda4dfd4e" => "/hello/world.html",
      "058ec3fa8aab4c0ccac27d80fd24f30a8730d3f6" => "/index.html"
    }
  end

  def test_sitemap_creation
    map = {
      "fake_sha1_1" => "/path/to/file_1",
      "fake_sha1_2" => "/path/to/file_2"
    }
    sitemap = StaticdUtils::Sitemap.new(map)
    assert_equal map, sitemap.to_h
  end

  def test_sitemap_routes
    sitemap = StaticdUtils::Sitemap.new(@hello_world_map)
    assert_equal ["/hello/world.html", "/index.html"], sitemap.routes
  end

  def test_sitemap_digest
    sitemap = StaticdUtils::Sitemap.new(@hello_world_map)
    assert_equal(
      [
        "92136ff551f50188f46486ab80db269eda4dfd4e",
        "058ec3fa8aab4c0ccac27d80fd24f30a8730d3f6"
      ],
      sitemap.digests
    )
  end

  def test_sitemap_creation_from_folder
    sitemap = StaticdUtils::Sitemap.create fixtures_path("sites/hello_world")
    assert_equal @hello_world_map, sitemap.to_h
  end

  def test_sitemap_export_to_yaml
    sitemap = StaticdUtils::Sitemap.create fixtures_path("sites/hello_world")
    assert @hello_world_map.to_yaml, sitemap.to_yaml
  end

  def test_sitemap_open_from_yaml
    sitemap = StaticdUtils::Sitemap.open @hello_world_map.to_yaml
    assert_equal @hello_world_map, sitemap.to_h
  end

  def test_sitemap_each_resources_iterator
    sitemap = StaticdUtils::Sitemap.new @hello_world_map
    sitemap.each_resources do |digest, path|
      assert @hello_world_map.keys.include? digest
      assert @hello_world_map.map{|key, value| value}.include? path
    end
  end
end

