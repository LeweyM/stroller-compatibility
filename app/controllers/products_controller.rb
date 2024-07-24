class ProductsController < ApplicationController
  def index
    @strollers = Product.where(productable_type: "Stroller").group_by(&:brand)
    @seats = Product.where(productable_type: "Seat").group_by(&:brand)
  end

  def show
  end

  def fits
    @product = Product.friendly.find(params[:slug])
    @other_products = Product.where.not(productable_type: @product.productable_type)
  end

  def compatible
    product_a = Product.friendly.find(params[:slug])
    product_b = Product.friendly.find(params[:b_id])
    @link = (CompatibleLink.where(product_a_id: product_a.id)
                           .and(CompatibleLink.where(product_b_id: product_b.id)))
              .or(CompatibleLink.where(product_a_id: product_b.id)
                                .and(CompatibleLink.where(product_b_id: product_a.id)))
              .first
  end

  private

end
