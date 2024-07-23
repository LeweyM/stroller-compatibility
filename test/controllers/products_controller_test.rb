require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "should get fits" do
    get products_fits_url
    assert_response :success
  end
end
