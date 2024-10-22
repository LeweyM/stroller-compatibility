require "test_helper"

class BrandTest < ActiveSupport::TestCase
  test "should return brands ordered by product count and total product count" do
    results, total_count = Brand.ordered_by_product_count_with_totals
    assert_equal [brands(:maxicosi), brands(:yoyo)], results
    assert_equal 4, total_count
  end

  test "export_to_csv returns correct headers and data" do
    csv_data = Brand.export_to_csv
    expected_csv = CSV.parse([
      'name,website',
      'maxicosi,http://www.maxicosi.com/',
      'yoyo,http://www.yoyo.com/'
    ].join("\n"))
    assert_equal expected_csv, CSV.parse(csv_data)
  end
end
