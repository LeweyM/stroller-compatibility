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
end
