require "test_helper"

module Test
  module StoreInterface
    include TestHelper

    def test_datastore_interface
      assert_respond_to @datastore, :put
      assert_respond_to @datastore, :exist?
    end
  end
end
