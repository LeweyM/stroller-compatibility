require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @stroller = create_product! type: Stroller
    @seat = create_product! type: Seat
    @adapter = create_product! type: Adapter
  end

  test "should get fits page" do
    get fits_product_url(slug: @stroller.slug)
    assert_response :success
    assert_not_nil assigns(:product)
    assert_not_nil assigns(:other_products)
  end

  test "should get compatability page" do
    get compatible_product_url(slug: @stroller.slug, b_id: @seat.slug)
    assert_response :success
  end

  test "compatibility page with incompatible products" do
    get compatible_product_url(slug: @stroller.slug, b_id: @seat.slug)
    assert_response :success
    assert_nil assigns(:adapter)
  end

  test "compatibility page with compatible products" do
    product_a = create_product! type: Stroller
    product_b = create_product! type: Seat
    create_product! type: Adapter # to check for interference
    adapter = create_product! type: Adapter
    create_product! type: Adapter # to check for interference
    product_a.link!(adapter)
    product_b.link!(adapter)

    get compatible_product_url(slug: product_a.slug, b_id: product_b.slug)
    assert_response :success
    assert_not_nil assigns(:product_a)
    assert_not_nil assigns(:product_b)
    assert_not_nil assigns(:adapter)
  end

  test "search_types should only include seat if product is a stroller" do
    get fits_product_url(slug: @stroller.slug)

    assert_response :success
    assert_equal assigns(:search_types), ["Seat"]
  end

  test "search_types should only include stroller if product is a seat" do
    get fits_product_url(slug: @seat.slug)

    assert_response :success
    assert_equal assigns(:search_types), ["Stroller"]
  end
end
