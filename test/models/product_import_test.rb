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
    file = prepare_test_file(@csv_headers + csv, "seats_test")
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
    file = prepare_test_file(@csv_headers + generate_csv_row(type: "bad_type"), "seats_test")

    assert_raises RuntimeError do
      Product.import(file)
    end
  end

  test "should create new brands if they do not exist" do
    row1 = generate_csv_row(brand: "maxicosi", type: "seat")
    row2 = generate_csv_row(brand: "somenewbrand", type: "seat")
    file = prepare_test_file(@csv_headers + row1 + row2, "seats_test")

    assert_difference 'Brand.count', 1 do
      Product.import(file)
    end
  end

  test "should associate products with the correct brand" do
    brand = Brand.create!(name: "BrandA")
    row = generate_csv_row(brand: "BrandA", type: "seat")
    file = prepare_test_file(@csv_headers + row, "seats_test")
    Product.import(file)
    assert_equal brand, Product.last.brand
  end

  test "should handle image creation correctly" do
    row = generate_csv_row(brand: "BrandA", type: "seat")
    file = prepare_test_file(@csv_headers + row, "seats_test")

    Product.import(file)
    assert_not_nil Product.last.image
  end

  test "should handle product creation without image" do
    row = generate_csv_row(type: "seat", image_url: nil)
    file = prepare_test_file(@csv_headers + row, "seats_test")

    Product.import(file)
    assert_nil Product.last.image
  end

  test "should import products with commas in names" do
    csv_content = @csv_headers + generate_csv_row(
      type: "Stroller",
      brand: "BrandX",
      name: "Deluxe, Comfy Stroller",
      link: "http://example.com",
      image_url: "http://example.com/image.jpg"
    )
    file = prepare_test_file(csv_content, "strollers_with_commas")

    assert_difference 'Product.count', 1 do
      Product.import(file)
    end

    product = Product.last
    assert_equal "Deluxe, Comfy Stroller", product.name
    assert_equal "BrandX", product.brand.name
    assert_equal "Stroller", product.productable_type
  end

  #  import_tags

  test "should import tags correctly" do
    csv = %w[maxicosi,maxicosi tag1,tag2 oxford,cabriofix cabriofix].join("\n")
    file = prepare_test_file(csv, "tags_test")

    Product.import_tags(file)

    tag_1 = Tag.find_by(label: "tag1")
    tag_2 = Tag.find_by(label: "tag2")
    assert_equal %w[oxford cabriofix].sort, tag_1.products.map(&:slug).sort
    assert_equal %w[cabriofix], tag_2.products.map(&:slug)
  end

  test "should not make any changes if one brand does not exist" do
    csv = %w[maxicosi,some-brand-that-doesnt-exist tag1,tag2 oxford,cabriofix cabriofix].join("\n")
    file = prepare_test_file(csv, "tags_test")

    assert_raises { Product.import_tags(file) }
    assert_nil Tag.find_by(label: "tag1")
    assert_nil Tag.find_by(label: "tag2")
  end

  test "should not make any changes if one product does not exist" do
    csv = %w[maxicosi,maxicosi tag1,tag2 oxford,cabriofix cabriofix,some-product-that-doesnt-exist].join("\n")
    file = prepare_test_file(csv, "tags_test")

    assert_raises { Product.import_tags(file) }
    assert_nil Tag.find_by(label: "tag1")
    assert_nil Tag.find_by(label: "tag2")
  end

end
