require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "should get all products for a tag" do
    infant_tag = tags(:infant)
    assert_equal 2, infant_tag.products.length
    assert_equal [products(:oxford), products(:cabriofix)].sort, infant_tag.products.sort
  end
end
