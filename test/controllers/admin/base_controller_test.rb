require "test_helper"

module Admin
  class BaseControllerTest < ActionDispatch::IntegrationTest
    setup do
      ENV['ADMIN_USERNAME'] = 'admin'
      ENV['ADMIN_PASSWORD'] = 'pw'
    end

    def http_login
      @username = ENV['ADMIN_USERNAME']
      @password = ENV['ADMIN_PASSWORD']
      { 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials(@username, @password) }
    end

    #  creates a product with random name
    #  type and brand are optional
    def create_product(type: Stroller, brand: brands(:maxicosi))
      p = type.create!
      name = type.class.name.split("::").last + "_" + Faker::Commerce.product_name
      Product.create!(name: name, brand: brand, productable: p)
    end
  end
end
