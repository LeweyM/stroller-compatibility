class Admin::BaseController < ApplicationController
  before_action :authenticate

  helper_method :is_admin?

  def is_admin?
    true
  end

  private

  def authenticate
    authenticate_or_request_with_http_basic('Administration') do |username, password|
      username == ENV['ADMIN_USERNAME'] && password == ENV['ADMIN_PASSWORD']
    end
  end
end
