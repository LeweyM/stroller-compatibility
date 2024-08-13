require "test_helper"

class Admin::ImagesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get new_admin_product_image_url(:oxford)
    assert_response :success
  end

  test "should get create" do
    post admin_product_images_url(:oxford)
    assert_response :success
  end

  test "should get destroy" do
    delete destroy_image_admin_product_url(:oxford)
    assert_response :found
  end
end
