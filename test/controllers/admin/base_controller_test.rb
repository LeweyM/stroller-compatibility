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
  end
end
