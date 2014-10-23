require "test_helper"
require "staticd/domain_generator"

class DomainGeneratorTest < MiniTest::Test
  include TestHelper

  def setup
    ENV["STATICD_WILDCARD_DOMAIN"] = "staticd.tld"
  end

  def test_it_should_generate_a_domain_name_from_a_word
    domain = Staticd::DomainGenerator.new("my_website")
    assert_instance_of String, domain
    assert_match /.*\.#{ENV["STATICD_WILDCARD_DOMAIN"]}/, domain
  end
end
