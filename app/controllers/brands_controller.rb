class BrandsController < ApplicationController
  # GET /brands or /brands.json
  def index
    @brands = Brand.all
  end

end
