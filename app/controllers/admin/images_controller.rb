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
end
