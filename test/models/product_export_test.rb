require 'test_helper'

class ProductExportTest < ActiveSupport::TestCase
  setup do
    @brand = Brand.create!(name: 'TestBrand')
    @stroller = create_product! type: Stroller, name: 'Stroller1', brand: @brand, url: 'http://example.com/stroller1', fix_name: true
    @seat = create_product! type: Seat, brand: @brand, name: 'Seat1', url: 'http://example.com/seat1', fix_name: true
    @adapter = Product.create!(productable: Adapter.create!, brand: @brand, name: 'Adapter1')

    @stroller.link! @adapter
    @seat.link! @adapter
  end

  test "export_all generates a CSV string with all products" do
    csv_raw = Product.export_all

    assert_csv_line %w[type brand name url image_url], csv_raw, 0
    assert_csv_includes_line ['Adapter', 'TestBrand', 'Adapter1', '', ''], csv_raw
    assert_csv_includes_line ['Seat', 'TestBrand', 'Seat1', 'http://example.com/seat1', ''], csv_raw
    assert_csv_includes_line ['Stroller', 'TestBrand', 'Stroller1', 'http://example.com/stroller1', ''], csv_raw
  end

  test "export_all sorts products by brand, type, and name" do
    brand1 = Brand.create!(name: 'BrandA')
    brand2 = Brand.create!(name: 'BrandB')

    create_product!(type: Stroller, name: 'StrollerB', brand: brand2, fix_name: true)
    create_product!(type: Seat, name: 'SeatA', brand: brand1, fix_name: true)
    create_product!(type: Stroller, name: 'StrollerA', brand: brand1, fix_name: true)
    create_product!(type: Seat, name: 'SeatB', brand: brand2, fix_name: true)

    csv_raw = Product.export_all

    assert_csv_line %w[type brand name url image_url], csv_raw, 0
    assert_csv_line ['Seat', 'BrandA', 'SeatA', '', ''], csv_raw, 1
    assert_csv_line ['Stroller', 'BrandA', 'StrollerA', '', ''], csv_raw, 2
    assert_csv_line ['Seat', 'BrandB', 'SeatB', '', ''], csv_raw, 3
    assert_csv_line ['Stroller', 'BrandB', 'StrollerB', '', ''], csv_raw, 4
  end

  test "export_compatible generates a CSV string with compatibility information" do
    csv_raw = Product.export_compatible

    # lines 0-5 are data from fixtures
    assert_csv_line ['Stroller1'], csv_raw, 6
    assert_csv_line ['Seat1'], csv_raw, 7
    assert_csv_line ['Adapter1'], csv_raw, 8
  end

  test "export_tags generates a CSV string with tag data" do
    csv_raw = Product.export_tags

    assert_csv_line ['maxicosi'], csv_raw, 0
    assert_csv_line ['infant'], csv_raw, 1
    assert_csv_line ['cabriofix'], csv_raw, 2
    assert_csv_line ['oxford'], csv_raw, 3
    assert_csv_line ['infant-adapter'], csv_raw, 4
  end

  test "export_tags generates a CSV string with tag data when more than 1 tags exist" do
    tag = Tag.create!(label: 'newborn', brand: brands(:maxicosi))
    oxford = products(:oxford)
    oxford.add_tag tag

    lines = Product.export_tags

    assert_csv_line ['maxicosi', 'maxicosi'], lines, 0
    assert_csv_line ['infant', 'newborn'], lines, 1
    assert_csv_line ['cabriofix', 'oxford'], lines, 2
    assert_csv_line ['oxford', ''], lines, 3
    assert_csv_line ['infant-adapter', ''], lines, 4
  end

  private

  def assert_csv_includes_line(expected, raw_csv)
    lines = raw_csv.split("\n")
    line_to_test = lines.find { |line|
      csv_parse = CSV.parse(line)
      csv_parse.include?(expected)
    }
    assert_not_nil line_to_test, "could not find line #{expected} in \n#{raw_csv}"
    assert_csv_line expected, raw_csv, lines.find_index(line_to_test)
  end

  def assert_csv_line(expected, actual, line_index)
    lines = actual.split("\n")
    line = lines[line_index]
    assert_csv_line_format(line)
    actual_csv = CSV.parse_line(line, liberal_parsing: true)
    assert_equal expected.size, actual_csv.size, "CSV line has incorrect number of fields"
    expected.zip(actual_csv).each_with_index do |(exp, act), index|
      if act.nil?
        assert_equal exp, "", "Field #{index} should be empty"
      else
        assert_equal exp, act.gsub(/^"|"$/, ''), "Field #{index} should be #{exp} but was #{act}"
      end
    end
  end

  def assert_csv_line_format(line)
    assert_match(/^"[^"]*"(,"[^"]*")*$/, line, "CSV line is not properly formatted with quotes")
  end
end