require "test_helper"
require_relative './base_controller_test'

class Admin::ProductsControllerTest < Admin::BaseControllerTest
  test "should get index" do
    get admin_products_url, headers: http_login
    assert_response :success
  end

  test "should get new" do
    get new_admin_product_url, headers: http_login
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_product_url(:oxford), headers: http_login
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
