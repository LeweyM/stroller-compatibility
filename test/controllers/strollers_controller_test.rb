require "test_helper"

class StrollersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @stroller = strollers(:one)
  end

  test "should get index" do
    get strollers_url
    assert_response :success
  end

  test "should get new" do
    get new_stroller_url
    assert_response :success
  end

  test "should create stroller" do
    assert_difference("Stroller.count") do
      post strollers_url, params: { stroller: { brand_id: @stroller.brand_id, name: @stroller.name } }
    end

    assert_redirected_to stroller_url(Stroller.last)
  end

  test "should show stroller" do
    get stroller_url(@stroller)
    assert_response :success
  end

  test "should get edit" do
    get edit_stroller_url(@stroller)
    assert_response :success
  end

  test "should update stroller" do
    patch stroller_url(@stroller), params: { stroller: { brand_id: @stroller.brand_id, name: @stroller.name } }
    assert_redirected_to stroller_url(@stroller)
  end

  test "should destroy stroller" do
    assert_difference("Stroller.count", -1) do
      delete stroller_url(@stroller)
    end

    assert_redirected_to strollers_url
  end
end
