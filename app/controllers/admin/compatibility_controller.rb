class Admin::CompatibilityController < Admin::BaseController
  def index
    @compatibility_links = CompatibleLink.all
  end
end
