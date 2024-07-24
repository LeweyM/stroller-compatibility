class ProductsController < ApplicationController
  def index
    @strollers = Product.where(productable_type: "Stroller").group_by(&:brand)
    @seats = Product.where(productable_type: "Seat").group_by(&:brand)
  end

  def show
  end

  def fits
    @product = Product.find(params[:id])
    @other_products = Product.where.not(productable_type: @product.productable_type)
  end

  def compatible
    @link = (CompatibleLink.where(product_a_id: params[:id])
                           .and(CompatibleLink.where(product_b_id: params[:b_id])))
              .or(CompatibleLink.where(product_a_id: params[:b_id])
                                .and(CompatibleLink.where(product_b_id: params[:id]))
              ).first
  end

  private

end
