require "test_helper"

class BrandTest < ActiveSupport::TestCase
  # ordered_by_product_count_with_totals

  test "should return brands ordered by product count and total product count" do
    results, total_count = Brand.ordered_by_product_count_with_totals
    assert_equal [brands(:maxicosi), brands(:yoyo)], results
    assert_equal 4, total_count
  end

  # export

  test "export_to_csv returns correct headers and data" do
    csv_data = Brand.export_to_csv
    expected_csv = CSV.parse([
                               'name,website',
                               'maxicosi,http://www.maxicosi.com/',
                               'yoyo,http://www.yoyo.com/'
                             ].join("\n"))
    assert_equal expected_csv, CSV.parse(csv_data)
  end

  # import

  class BrandImportTest < ActiveSupport::TestCase

    def setup_csv_file(csv_data)
      file = Tempfile.new(['test', '.csv'])
      file.write(csv_data)
      file.rewind
      file
    end

    def cleanup_file(file)
      file.close
      file.unlink
    end

    test "import should create new brands" do
      csv_data = "name,website\nnewbrand,http://www.newbrand.com\nanotherbrand,http://www.anotherbrand.com"
      file = setup_csv_file(csv_data)

      assert_difference 'Brand.count', 2 do
        Brand.import(file)
      end
      cleanup_file(file)
    end

    test "import should ignore existing brands" do
      csv_data = "name,website\nmaxicosi,http://www.maxicosi.com\nanotherbrand,http://www.anotherbrand.com"
      file = setup_csv_file(csv_data)

      assert_difference 'Brand.count', 1 do
        Brand.import(file)
      end
      cleanup_file(file)
    end
  end
end