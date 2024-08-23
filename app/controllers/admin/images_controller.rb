class Admin::ImagesController < ApplicationController
  def new
  end

  def create
  end

  def destroy_image
    @product = Product.friendly.find(params[:id])
    @image = @product.image
    @image.destroy
    redirect_to admin_products_path, notice: 'Product image was successfully deleted.'
  end

  def generate
    # use google client to find an image url for the product
    # and create a new image record with first result

    @product = Product.friendly.find(params[:product_id])
    @image = Image.new
    @image.product = @product

    client = GoogleApiService.new
    begin
      results = client.image_search(@product)
      @image.url = results.first["link"]
      @image.save
      flash[:success] = "Image for #{@product.name} created."
      redirect_to edit_admin_product_path(@product)
    rescue => e
      logger.error "Failed to search image: #{e.message}"
      flash[:error] = "No image found for #{@product.name}."
      redirect_to edit_admin_product_path(@product)
      return
    end
  end
end
