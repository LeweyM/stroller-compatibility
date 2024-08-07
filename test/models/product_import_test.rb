require "test_helper"

class ProductImportTest < ActiveSupport::TestCase
  setup do
    @csv_headers = "type,brand,name,link,image_url\n"
  end

  def generate_csv_row(defaults = {})
    # Generate a unique name using a timestamp or a sequence number
    unique_suffix = Time.now.to_i.to_s + rand(1000).to_s

    # Define default values for each column, ensuring 'name' is always unique
    defaults = {
      type: "seat",
      brand: "defaultBrand",
      name: "defaultName_#{unique_suffix}",
      link: "http://example.com/default",
      image_url: "http://example.com/default.jpg"
    }.merge(defaults)

    # Override the name specifically if provided
    defaults[:name] = "#{defaults[:name]}_#{unique_suffix}" unless defaults.key?(:name)

    # Create a CSV row string
    "#{defaults[:type]},#{defaults[:brand]},#{defaults[:name]},#{defaults[:link]},#{defaults[:image_url]}\n"
  end

  def prepare_test_file(content, filename)
    temp_file = Tempfile.new([filename, '.csv'])
    temp_file.write(content)
    temp_file.rewind
    Rack::Test::UploadedFile.new(temp_file, "text/csv", original_filename: "test-seats.csv")
  end

  test "should import products from a CSV file with valid data" do
    csv = [
      generate_csv_row(brand: "maxicosi", type: "seat"),
      generate_csv_row(brand: "maxicosi", type: "seat"),
      generate_csv_row(brand: "maxicosi", type: "seat")
    ].join
    file = prepare_test_file(@csv_headers + csv, "test-seats")
    assert_difference 'Product.count', 3 do
      Product.import(file)
    end
  end

  test "should raise an error for unknown product types" do
    file = prepare_test_file(@csv_headers + generate_csv_row(type: "bad_type"), "test-seats")

    assert_raises RuntimeError do
      Product.import(file)
    end
  end

  test "should create new brands if they do not exist" do
    row1 = generate_csv_row(brand: "maxicosi", type: "seat")
    row2 = generate_csv_row(brand: "somenewbrand", type: "seat")
    file = prepare_test_file(@csv_headers + row1 + row2, "test-seats")

    assert_difference 'Brand.count', 1 do
      Product.import(file)
    end
  end

  test "should associate products with the correct brand" do
    brand = Brand.create!(name: "BrandA")
    row = generate_csv_row(brand: "BrandA", type: "seat")
    file = prepare_test_file(@csv_headers + row, "test-seats")
    Product.import(file)
    assert_equal brand, Product.last.brand
  end

  test "should handle image creation correctly" do
    row = generate_csv_row(brand: "BrandA", type: "seat")
    file = prepare_test_file(@csv_headers + row, "test-seats")

    Product.import(file)
    assert_not_nil Product.last.image
  end

  test "should handle product creation without image" do
    row = generate_csv_row(type: "seat", image_url: nil)
    file = prepare_test_file(@csv_headers + row, "test-seats")

    Product.import(file)
    assert_nil Product.last.image
  end
end
