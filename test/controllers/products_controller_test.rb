require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get fits" do
    get fits_product_url slug: 'oxford'
    assert_response :success
  end
end
