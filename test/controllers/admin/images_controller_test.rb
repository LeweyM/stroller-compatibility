require "test_helper"

class Admin::ImagesControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get admin_images_new_url
    assert_response :success
  end

  test "should get create" do
    get admin_images_create_url
    assert_response :success
  end

  test "should get destroy" do
    get admin_images_destroy_url
    assert_response :success
  end
end
