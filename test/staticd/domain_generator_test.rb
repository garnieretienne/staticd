require "test_helper"
require "staticd/domain_generator"

class DomainGeneratorTest < Minitest::Unit::TestCase
  include TestHelper

  def setup
    @domain = ".staticd.tld"
  end

  def test_it_should_generate_a_domain_name
    domain = Staticd::DomainGenerator.new(suffix: @domain)
    assert_instance_of String, domain
    assert_match /.*#{@domain}/, domain
  end
end
