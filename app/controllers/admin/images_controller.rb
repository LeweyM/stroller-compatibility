class Admin::ImagesController < ApplicationController
  def new
  end

  def create
  end

  def destroy
    @image = Image.find(params[:id])
    @image.destroy
    redirect_to admin_products_path, notice: 'Product image was successfully deleted.'
  end


  def generate
    # use google client to find an image url for the product
    # and create a new image record with first result

    @product = Product.friendly.find(params[:product_id])
    @image = Image.new
    @image.product = @product

    google_url = "https://www.googleapis.com/customsearch/v1?"
    params = {
      cx: ENV['GOOGLE_CLIENT_CX'],
      key: ENV['GOOGLE_CLIENT_API_KEY'],
      searchType: "image",
      q: "site:#{@product.brand.website} #{@product.name}"
    }

    response = HTTParty.get(google_url, query: params)
    parsed_response = JSON.parse(response.body)
    if parsed_response["searchInformation"]["totalResults"] == 0 or parsed_response["items"].nil?
      flash[:error] = "No image found for #{@product.name}."
      redirect_to edit_admin_product_path(@product)
      return
    end

    first_item = parsed_response["items"].first
    @image.url = first_item["link"]

    @image.save
    flash[:success] = "Image for #{@product.name} created."
    redirect_to edit_admin_product_path(@product)
  end
end
