class ProductsController < ApplicationController
  def index
    @strollers = Product.where(productable_type: "Stroller").group_by(&:brand)
    @seats = Product.where(productable_type: "Seat").group_by(&:brand)
  end

  def show
  end

  def search
    query = Product.where("LOWER(name) ILIKE LOWER(?)", "%#{params[:search_term]}%")
    # optional type query param
    if params[:type].present?
      query = query.where(productable_type: params[:type])
    end
    result = query.limit(15)
                  .pluck(:slug, :name)
                  .map { |slug, name| { slug: slug, name: name } }
    render json: result
  end

  def search_comparison
    query_result = Product
                     .where(productable_type: params[:type])
                     .where("name ILIKE ?", "%#{params[:search_term]}%")
                     .limit(15)
                     .pluck(:slug, :name)
    result = query_result.map { |slug, name| { slug: slug, name: name } }
    render json: result
  end

  def fits
    @product = Product.friendly.find(params[:slug])
    @other_products = Product.where.not(productable_type: @product.productable_type)
  end

  def compatible
    @product_a = Product.friendly.find(params[:slug])
    @product_b = Product.friendly.find(params[:b_id])
    @link = (CompatibleLink.where(product_a_id: @product_a.id)
                           .and(CompatibleLink.where(product_b_id: @product_b.id)))
              .or(CompatibleLink.where(product_a_id: @product_b.id)
                                .and(CompatibleLink.where(product_b_id: @product_a.id)))
              .first
    @adapter = @link.adapter if @link
    @suggested_products = @product_a.compatible_products
  end

  private

end
