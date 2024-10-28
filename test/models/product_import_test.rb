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
      brand: "maxicosi",
      name: "defaultName_#{unique_suffix}",
      link: "http://example.com/default",
      image_url: "http://example.com/default.jpg"
    }.merge(defaults)

    # Override the name specifically if provided
    defaults[:name] = "#{defaults[:name]}_#{unique_suffix}" unless defaults.key?(:name)

    # Create a CSV row string
    CSV.generate_line([defaults[:type], defaults[:brand], defaults[:name], defaults[:link], defaults[:image_url]], force_quotes: true)
  end

  def prepare_test_file(content, filename)
    temp_file = Tempfile.new([filename, '.csv'])
    temp_file.write(content)
    temp_file.rewind
    Rack::Test::UploadedFile.new(temp_file, "text/csv", original_filename: filename + ".csv")
  end

  test "should import products from a CSV file with valid data" do
    csv = [
      generate_csv_row(brand: "maxicosi", type: "seat"),
      generate_csv_row(brand: "maxicosi", type: "seat"),
      generate_csv_row(brand: "maxicosi", type: "seat")
    ].join
    file = prepare_test_file(@csv_headers + csv, "product_test")
    assert_difference 'Product.count', 3 do
      Product.import(file)
    end
  end

  test "should not raise errors when importing duplicate compatibility" do
    # Create initial products and adapter
    stroller = create_product!(type: Stroller, name: "TestStroller", fix_name: true)
    seat = create_product!(type: Seat, name: "TestSeat", fix_name: true)
    adapter = create_product!(type: Adapter, name: "TestAdapter", fix_name: true)

    # Create initial CSV content
    csv_content = "TestStroller\nTestSeat\nTestAdapter"
    file = prepare_test_file(csv_content, "compatible_test")

    # Import compatibility for the first time
    assert_nothing_raised do
      Product.import(file)
    end

    # Try to import the same compatibility again
    assert_nothing_raised do
      Product.import(file)
    end

    # Verify that the links still exist and weren't duplicated
    assert_equal 1, stroller.product_adapters.where(adapter: adapter.productable).count
    assert_equal 1, seat.product_adapters.where(adapter: adapter.productable).count
  end

  test "should raise an error for unknown product types" do
    file = prepare_test_file(@csv_headers + generate_csv_row(type: "bad_type"), "product_test")

    assert_raises RuntimeError do
      Product.import(file)
    end
  end

  test "should raise an error for unknown brands and no new products should be added" do
    row1 = generate_csv_row(brand: "maxicosi", type: "seat")
    row2 = generate_csv_row(brand: "somenewbrand", type: "seat")
    file = prepare_test_file(@csv_headers + row1 + row2, "product_test")

    assert_difference ['Brand.count', 'Product.count'], 0 do
      assert_raises RuntimeError do
        Product.import(file)
      end
    end
  end

  test "should associate products with the correct brand" do
    brand = Brand.create!(name: "BrandA")
    row = generate_csv_row(brand: "BrandA", type: "seat")
    file = prepare_test_file(@csv_headers + row, "product_test")
    Product.import(file)
    assert_equal brand, Product.last.brand
  end

  test "should handle image creation correctly" do
    row = generate_csv_row(type: "seat")
    file = prepare_test_file(@csv_headers + row, "product_test")

    Product.import(file)
    assert_not_nil Product.last.image
  end

  test "should handle product creation without image" do
    row = generate_csv_row(type: "seat", image_url: nil)
    file = prepare_test_file(@csv_headers + row, "product_test")

    Product.import(file)
    assert_nil Product.last.image
  end

  test "should import products with commas in names" do
    csv_content = @csv_headers + generate_csv_row(
      type: "Stroller",
      name: "Deluxe, Comfy Stroller",
      link: "http://example.com",
      image_url: "http://example.com/image.jpg"
    )
    file = prepare_test_file(csv_content, "product")

    assert_difference 'Product.count', 1 do
      Product.import(file)
    end

    product = Product.last
    assert_equal "Deluxe, Comfy Stroller", product.name
    assert_equal "Stroller", product.productable_type
  end

  test "should return with the count of new products added" do
    Brand.create!(name: "BrandA")
    Brand.create!(name: "BrandB")
    create_product! name: "ignored_product_because_already_exists", fix_name: true

    row1 = generate_csv_row(brand: "BrandA", type: "seat")
    row2 = generate_csv_row(brand: "BrandB", type: "stroller")
    row3 = generate_csv_row(brand: "maxicosi", type: "stroller", name: "ignored_product_because_already_exists")
    file = prepare_test_file(@csv_headers + row1 + row2 + row3, "product_test")

    result = Product.import(file)
    assert_equal 2, result
  end
end
