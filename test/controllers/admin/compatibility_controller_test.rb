require "test_helper"
require_relative './base_controller_test'

class Admin::CompatibilityControllerTest < Admin::BaseControllerTest
  test "index action groups compatibility links by adapter" do
    p1 = create_product! type: Stroller
    p2 = create_product! type: Seat
    adapter1 = create_product! type:Adapter
    adapter2 = create_product! type:Adapter
    p1.link!(p2, adapter1)
    p1.link!(p2, adapter2)

    get admin_compatibility_index_path, headers: http_login

    assert_response :success
    assert_equal 2, assigns(:compatibility_links).keys.count
    assert_includes assigns(:compatibility_links).keys, adapter1
    assert_includes assigns(:compatibility_links).keys, adapter2
  end

  test "index action groups products by productable_type" do
    adapter = create_product!(type: Adapter)
    create_product!(type: Stroller).link!(create_product!(type: Seat), adapter)
    create_product!(type: Stroller).link!(create_product!(type: Seat), adapter)

    get admin_compatibility_index_path, headers: http_login

    assert_response :success
    grouped_products = assigns(:compatibility_links)[adapter]
    assert_equal 2, grouped_products.keys.count
    assert_includes grouped_products.keys, "Stroller"
    assert_includes grouped_products.keys, "Seat"
  end

  test "index action removes duplicate products" do
    adapter = create_product!(type: Adapter)
    product_a = create_product!(type: Stroller)
    product_b = create_product!(type: Seat)
    product_a.link!(product_b, adapter)
    product_b.link!(product_a, adapter)

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
