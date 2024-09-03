require "test_helper"
require_relative './base_controller_test'

class Admin::BrandsControllerTest < Admin::BaseControllerTest

  test "should get index" do
    get brands_url
    assert_response :success
  end

end
