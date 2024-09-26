require "test_helper"

class BrandTest < ActiveSupport::TestCase
  test "should return brands ordered by product count and total product count" do
    results, total_count = Brand.ordered_by_product_count_with_totals
    assert_equal [brands(:maxicosi), brands(:yoyo)], results
    assert_equal 4, total_count
  end

end
