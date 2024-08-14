require "test_helper"
require_relative './base_controller_test'

class Admin::CompatibilityControllerTest < Admin::BaseControllerTest
  test "index action groups compatibility links by adapter" do
    adapter1 = Product.create!(name: 'adapter1', productable: Adapter.create!, brand: brands(:maxicosi))
    adapter2 = Product.create!(name: 'adapter2', productable: Adapter.create!, brand: brands(:maxicosi))
    link1 = CompatibleLink.create!(adapter: adapter1, product_a: products(:oxford), product_b: products(:cabriofix))
    link2 = CompatibleLink.create!(adapter: adapter1, product_a: products(:oxford), product_b: products(:cabriofix))
    link3 = CompatibleLink.create!(adapter: adapter2, product_a: products(:oxford), product_b: products(:cabriofix))

    get admin_compatibility_index_path, headers: http_login

    assert_response :success
    assert_equal 2, assigns(:compatibility_links).keys.count
    assert_includes assigns(:compatibility_links).keys, adapter1
    assert_includes assigns(:compatibility_links).keys, adapter2
  end

  test "index action groups products by productable_type" do
    adapter = create_product(type: Adapter)
    product_a1 = create_product(type: Stroller)
    product_a2 = create_product(type: Seat)
    product_b1 = create_product(type: Stroller)
    product_b2 = create_product(type: Seat)
    link1 = CompatibleLink.create!(adapter: adapter, product_a: product_a1, product_b: product_b1)
    link2 = CompatibleLink.create!(adapter: adapter, product_a: product_a2, product_b: product_b2)

    get admin_compatibility_index_path, headers: http_login

    assert_response :success
    grouped_products = assigns(:compatibility_links)[adapter]
    assert_equal 2, grouped_products.keys.count
    assert_includes grouped_products.keys, "Stroller"
    assert_includes grouped_products.keys, "Seat"
  end

  test "index action removes duplicate products" do
    adapter = create_product(type: Adapter)
    product_a = create_product(type: Stroller)
    product_b = create_product(type: Seat)
    link1 = CompatibleLink.create!(adapter: adapter, product_a: product_a, product_b: product_b)
    link2 = CompatibleLink.create!(adapter: adapter, product_a: product_a, product_b: product_b)
    link3 = CompatibleLink.create!(adapter: adapter, product_a: product_b, product_b: product_a)

    get admin_compatibility_index_path, headers: http_login

    assert_response :success
    grouped_products = assigns(:compatibility_links)[adapter]
    assert_equal 1, grouped_products["Stroller"].count
    assert_equal 1, grouped_products["Seat"].count
  end

  test "index action handles empty compatibility links" do
    get admin_compatibility_index_path, headers: http_login

    assert_response :success
    assert_empty assigns(:compatibility_links)
  end
end
