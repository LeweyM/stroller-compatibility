require "test_helper"

class Admin::ProductsControllerTest < ActionDispatch::IntegrationTest
  setup do
    ENV['ADMIN_USERNAME'] = 'admin'
    ENV['ADMIN_PASSWORD'] = 'pw'
  end

  def http_login
    @username = ENV['ADMIN_USERNAME']
    @password = ENV['ADMIN_PASSWORD']
    { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@username, @password)}
  end

  test "should get index" do
    get admin_products_url, headers: http_login
    assert_response :success
  end

  test "should get new" do
    get new_admin_product_url, headers: http_login
    assert_response :success
  end

  test "should get edit" do
    get edit_admin_product_url(:oxford), headers: http_login
    assert_response :success
  end

  test "should update a product" do
    new_link = "https://www.maxi-cosi.com/updated-link"
    patch admin_product_url(:oxford),
          headers: http_login,
          params: { product: { link: new_link } }
    assert_response :success
    assert_equal new_link, Product.find_by(name: "oxford").link
  end
end
