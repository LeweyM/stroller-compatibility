require "test_helper"

class Admin::BrandsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get admin_brands_index_url
    assert_response :success
  end

  test "should get show" do
    get admin_brands_show_url
    assert_response :success
  end

  test "should get new" do
    get admin_brands_new_url
    assert_response :success
  end

  test "should get edit" do
    get admin_brands_edit_url
    assert_response :success
  end
end
