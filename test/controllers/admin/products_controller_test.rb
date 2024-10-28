require "test_helper"
require_relative './base_controller_test'

class Admin::ProductsControllerTest < Admin::BaseControllerTest
  test "should get new" do
    get new_admin_product_url, headers: http_login
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_product_url(:oxford), headers: http_login
    assert_response :success
  end

  test "should create a new product without image" do
    assert_difference('Product.count') do
      brand = brands(:maxicosi)
      post admin_products_url, params: {
        product: {
          name: 'Test Seat',
          brand: brand.id,
          productable_type: 'Seat',
          url: "www.somewebsite.com",
        }
      },
           headers: http_login
    end

    last_product = Product.last
    assert_redirected_to edit_admin_product_path(last_product)
    assert_not last_product.has_image?
    assert_equal 'Product was successfully created.', flash[:notice]
  end

  test "should create a new product with image" do
    brand = brands(:maxicosi)
    assert_difference('Product.count') do
      post admin_products_url, params: {
        product: {
          name: 'Test Seat',
          brand: brand.id,
          productable_type: 'Seat',
          url: "www.somewebsite.com",
        }, image_url: "www.somewebsite.com/image"
      },
           headers: http_login
    end

    last_product = Product.last
    assert_redirected_to edit_admin_product_path(last_product)
    assert last_product.has_image?
    assert_equal 'Product was successfully created.', flash[:notice]
  end
end

class Admin::ProductsControllerIndexTest < Admin::BaseControllerTest
  test "should get index" do
    get admin_products_url, headers: http_login
    assert_response :success
  end

  test "should filter products by search" do
    get admin_products_url(search: "example"), headers: http_login
    assert_response :success
    assert_select "table" do
      assert_select "tr", count: Product.where("name ILIKE ?", "%example%").count + 1
    end
  end

  test "should filter products by type" do
    get admin_products_url(type: "stroller"), headers: http_login
    assert_response :success
    assert_select "table" do
      assert_select "tr", count: Product.where(productable_type: "Stroller").count + 1
    end
  end

  test "should filter products by brand" do
    brand = Brand.create(name: "TestBrand")
    Product.create(name: "Test Product", brand: brand, productable_type: "Stroller")
    get admin_products_url(brand: "testbrand"), headers: http_login
    assert_response :success
    assert_select "table" do
      assert_select "tr", count: Product.joins(:brand).where(brands: { name: "TestBrand" }).count + 1
    end
  end

  test "should order products by productable_type" do
    get admin_products_url, headers: http_login
    assert_response :success
    assert_select "table" do
      header_index = css_select("thead th").map(&:text).index('Type') + 1
      previous_type = nil
      css_select("tr td:nth-child(#{header_index})").each do |td|
        current_type = td.text
        assert previous_type <= current_type unless previous_type.nil?
        previous_type = current_type
      end
    end
  end

  test "should handle empty search results" do
    get admin_products_url(search: "nonexistent"), headers: http_login
    assert_response :success
    assert_select "table" do
      assert_select "tr", count: 1
    end
  end

  test "should handle multiple filters" do
    brand = Brand.create(name: "MultiBrand")
    Product.create(name: "Multi Filter Test", brand: brand, productable_type: "Stroller")
    get admin_products_url(search: "filter", type: "stroller", brand: "multibrand"), headers: http_login
    assert_response :success
    assert_select "table" do
      assert_select "tr", count: Product.joins(:brand)
                                        .where("products.name ILIKE ?", "%filter%")
                                        .where(productable_type: "Stroller")
                                        .where(brands: { name: "MultiBrand" })
                                        .count + 1
    end
  end

  test "should handle case-insensitive search" do
    Product.create!(name: "UPPERCASE PRODUCT", brand: brands(:maxicosi), productable: Stroller.create!)
    get admin_products_url(search: "uppercase"), headers: http_login
    assert_response :success
    assert_select "table" do
      assert_select "tr", count: 2 # Header + 1 product
    end
  end

  test "should handle multiple words in search" do
    Product.create!(name: "Multi Word Product Name", brand: brands(:maxicosi), productable: Stroller.create!)
    get admin_products_url(search: "word product"), headers: http_login
    assert_response :success
    assert_select "table" do
      assert_select "tr", count: 2 # Header + 1 product
    end
  end

  test "should handle case-insensitive type filter" do
    Product.create(name: "Test Stroller", productable_type: "Stroller")
    get admin_products_url(type: "stroller"), headers: http_login
    assert_response :success
    assert_select "table" do
      assert_select "tr", count: 2 # Header + 1 product
    end
  end

  test "should handle case-insensitive brand filter" do
    brand = Brand.create!(name: "CaseSensitiveBrand")
    stroller = Stroller.create!
    Product.create!(name: "Brand Test Product", brand: brand, productable: stroller)
    get admin_products_url(brand: "casesensitivebrand"), headers: http_login
    assert_response :success
    assert_select "table" do
      assert_select "tr", count: 2 # Header + 1 product
    end
  end

  test "should handle products with no brand" do
    Product.create(name: "No Brand Product", productable_type: "Stroller")
    get admin_products_url, headers: http_login
    assert_response :success
    assert_select "table" do
      assert_select "tr", count: Product.count + 1 # All products + header
    end
  end

  test "should handle invalid type filter" do
    get admin_products_url(type: "invalid_type"), headers: http_login
    assert_response :success
    assert_select "table" do
      assert_select "tr", count: 1 # Only header
    end
  end

  test "should handle invalid brand filter" do
    get admin_products_url(brand: "nonexistent_brand"), headers: http_login
    assert_response :success
    assert_select "table" do
      assert_select "tr", count: 1 # Only header
    end
  end
end

class Admin::ProductsControllerSearchTest < ActionDispatch::IntegrationTest
  test "should return search results" do
    get products_search_url(search_term: "oxford"), as: :json

    assert_response :success
    assert_equal "application/json", @response.media_type
    results = JSON.parse(@response.body)
    assert_instance_of Array, results
    assert_not_empty results
    assert_equal %w[slug name brand], results.first.keys
  end

  test "should limit search results to 15" do
    20.times { |i| create_product!(name: "Test Product #{i}") }
    get products_search_url(search_term: "Test"), as: :json
    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 15, results.length
  end

  test "should filter search results by type" do
    stroller = create_product!(name: "Test Stroller", type: Stroller)
    car_seat = create_product!(name: "Test Car Seat", type: Seat)

    get products_search_url(search_term: "Test", type: "Stroller"), as: :json

    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 1, results.length
    assert_equal stroller.slug, results.first["slug"]
  end

  test "should handle multiple types in search" do
    stroller = create_product!(name: "Test Stroller", type: Stroller)
    car_seat = create_product!(name: "Test Car Seat", type: Seat)

    get products_search_url(search_term: "Test", type: ["Stroller", "Seat"]), as: :json

    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 2, results.length
    assert_includes results.map { |r| r["slug"] }, stroller.slug
    assert_includes results.map { |r| r["slug"] }, car_seat.slug
  end

  test "should return empty array for no results" do
    get products_search_url(search_term: "NonexistentProduct"), as: :json
    assert_response :success
    results = JSON.parse(@response.body)
    assert_empty results
  end

  test "should handle empty search term" do
    get products_search_url(search_term: ""), as: :json

    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal Product.count, results.length
  end

  test "should be case insensitive" do
    create_product! type: Stroller, name: "UPPERCASE PRODUCT"

    get products_search_url(search_term: "uppercase"), as: :json

    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 1, results.length
    assert results.first["name"].starts_with? "UPPERCASE PRODUCT"
  end

  test "should handle special characters in search term" do
    create_product!(name: "Product with % and _", type: Stroller)

    get products_search_url(search_term: "% and _"), as: :json

    assert_response :success
    results = JSON.parse(@response.body)
    assert_equal 1, results.length
    assert results.first["name"].starts_with? "Product with % and _"
  end
end

class Admin::ProductsImportControllerTest < Admin::BaseControllerTest
  def create_test_file(content: "test", content_type: "text/csv", original_filename: "product.csv")
    Rack::Test::UploadedFile.new(StringIO.new(content),
                                 content_type,
                                 original_filename: original_filename)
  end

  def file_matching(file)
    ->(actual_file) {
      actual_file.original_filename == file.original_filename &&
        actual_file.content_type == file.content_type &&
        actual_file.read == file.read
    }
  end

  class IntegrationTests < Admin::ProductsImportControllerTest

    test "should import the new products, brands, tags and compatability data" do
      files = [
        file_fixture_upload("product.csv", "text/csv"),
        file_fixture_upload("tags.csv", "text/csv"),
        # order is important here as brands should always be processed first
        file_fixture_upload("brands.csv", "text/csv"),
      ]

      assert_difference -> { Product.count } => 2,
                        -> { Brand.count } => 1,
                        -> { ProductsTag.count } => 1,
                        -> { Tag.count } => 1 do
        post import_admin_products_url, params: { files: files }, headers: http_login
      end

      assert_equal "1 Brand, 2 Products, 1 Tag imported successfully", flash[:notice]
    end

  end

  class UnitTests < Admin::ProductsImportControllerTest

    test "should call Brand.import for files starting with 'brands'" do
      file = create_test_file(original_filename: "brands.csv")
      Brand.expects(:import).with(&file_matching(file))

      post import_admin_products_url, params: { files: [file] }, headers: http_login

      assert_response :found
    end

    test "should call Product.import for files starting with 'product'" do
      file = create_test_file(original_filename: "product.csv")
      Product.expects(:import).with(&file_matching(file))

      post import_admin_products_url, params: { files: [file] }, headers: http_login

      assert_response :found
    end

    test "should call Product.import for files starting with 'matrix'" do
      file = create_test_file(original_filename: "matrix.csv")
      Product.expects(:import).with(&file_matching(file))

      post import_admin_products_url, params: { files: [file] }, headers: http_login

      assert_response :found
    end

    test "should call Product.import for files starting with 'compatible'" do
      file = create_test_file original_filename: "compatible.csv"
      Product.expects(:import).with(&file_matching(file))

      post import_admin_products_url, params: { files: [file] }, headers: http_login

      assert_response :found
    end

    test "should call Product.import for files starting with 'tags'" do
      file = create_test_file original_filename: "tags.csv"
      Product.expects(:import).with(&file_matching(file))

      post import_admin_products_url, params: { files: [file] }, headers: http_login

      assert_response :found
    end

    test "should reject files with invalid names" do
      file = create_test_file original_filename: "some_invalid_filename.csv"

      post import_admin_products_url, params: { files: [file] }, headers: http_login

      assert_response :unprocessable_entity
      assert_equal "Error importing products: Unknown filename 'some_invalid_filename.csv'. Filename must begin with one of product, matrix, compatible, tags, brands", flash[:error]
    end

  end
end