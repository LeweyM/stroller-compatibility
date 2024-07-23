class ProductsController < ApplicationController
  def fits
    @product = Product.find(params[:id])
    @other_products = Product.where.not(productable_type: @product.productable_type)
  end

  def compatible
  end

  private

end
