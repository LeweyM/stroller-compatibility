require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @product = products(:oxford)
  end

  test "should get fits page" do
    get fits_product_url(slug: @product.slug)
    assert_response :success
    assert_not_nil assigns(:product)
    assert_not_nil assigns(:other_products)
  end

  test "search_types should not include the same type as the product" do
    get fits_product_url(slug: @product.slug)

    assert_response :success
    assert_not_nil assigns(:search_types)
    assert_not_includes assigns(:search_types), @product.productable_type
    assert_includes assigns(:search_types), "Adapter"
    assert_includes assigns(:search_types), "Seat"
  end
end
