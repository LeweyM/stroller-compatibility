require "test_helper"
require_relative './base_controller_test'

class Admin::CompatibilityControllerTest < Admin::BaseControllerTest
  test "index action groups compatibility links by adapter" do
    get admin_compatibility_index_path, headers: http_login

    assert_response :success
    assert_equal 2, assigns(:adapters_with_products_by_type).keys.count
    assert_includes assigns(:adapters_with_products_by_type).keys, adapters(:maxicosi_infant_adapter).product
    assert_includes assigns(:adapters_with_products_by_type).keys, adapters(:global_adapter).product
  end

  test "index action groups products by productable_type" do
    adapter = create_product!(type: Adapter)
    p_1 = create_product!(type: Stroller)
    p_2 = create_product!(type: Seat)
    p_1.link! adapter
    p_2.link! adapter

    get admin_compatibility_index_path, headers: http_login

    assert_response :success
    grouped_products = assigns(:adapters_with_products_by_type)[adapter]
    assert_equal 2, grouped_products.keys.count
    assert_includes grouped_products.keys, "Stroller"
    assert_includes grouped_products.keys, "Seat"
  end

  test "index action shows grouped products" do
    adapter = create_product!(type: Adapter)
    p1 = create_product!(type: Stroller)
    p2 = create_product!(type: Seat)
    p1.link! adapter
    p2.link! adapter

    get admin_compatibility_index_path, headers: http_login

    assert_response :success
    grouped_products = assigns(:adapters_with_products_by_type)[adapter]
    assert_equal 1, grouped_products["Stroller"].count
    assert_equal 1, grouped_products["Seat"].count
  end

  test "Seat and Stroller should be keys by default" do
    adapter = create_product!(type: Adapter)

    get admin_compatibility_index_path, headers: http_login

    assert_response :success
    assert_equal 2, assigns(:adapters_with_products_by_type)[adapter].keys.count
    assert_equal assigns(:adapters_with_products_by_type)[adapter]["Stroller"], []
    assert_equal assigns(:adapters_with_products_by_type)[adapter]["Seat"], []
  end

  # /unlink

  test "unlink should error if unable to link" do
    adapter = create_product!(type: Adapter)
    p1 = create_product!(type: Stroller)

    delete unlink_admin_compatibility_index_path, headers: http_login, params: {
      adapter: adapter.id,
      product_a: p1.id
    }

    assert_response :unprocessable_entity
  end
end
