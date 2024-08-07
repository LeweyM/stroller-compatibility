require "test_helper"

class BrandsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @brand = brands(:maxicosi)
  end

  test "should get index" do
    get brands_url
    assert_response :success
  end

end
