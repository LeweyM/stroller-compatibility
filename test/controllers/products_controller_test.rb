require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product_a = create_product! type:Stroller
    @product_b = create_product! type:Seat
    @adapter = create_product! type: Adapter
  end

  test "should get fits page" do
    get fits_product_url(slug: @product_a.slug)
    assert_response :success
    assert_not_nil assigns(:product)
    assert_not_nil assigns(:other_products)
  end

  test "should get compatability page" do
    get compatible_product_url(slug: @product_a.slug, b_id: @product_b.slug)
    assert_response :success
  end

  test "compatibility page with incompatible products" do
    get compatible_product_url(slug: @product_a.slug, b_id: @product_b.slug)
    assert_response :success
    assert_nil assigns(:adapter)
  end

  test "compatibility page with compatible products" do
    # skip "flaky, not sure why, so skipping"

    product_a = create_product! type:Stroller
    product_b = create_product! type:Seat
    create_product! type: Adapter
    adapter = create_product! type: Adapter
    create_product! type: Adapter
    product_a.link!(adapter)
    product_b.link!(adapter)

    get compatible_product_url(slug: product_a.slug, b_id: product_b.slug)
    assert_response :success
    assert_not_nil assigns(:product_a)
    assert_not_nil assigns(:product_b)
    assert_not_nil assigns(:adapter)
  end

  test "search_types should not include the same type as the product" do
    get fits_product_url(slug: @product_a.slug)

    assert_response :success
    assert_not_nil assigns(:search_types)
    assert_not_includes assigns(:search_types), @product_a.productable_type
    assert_includes assigns(:search_types), "Adapter"
    assert_includes assigns(:search_types), "Seat"
  end
end
