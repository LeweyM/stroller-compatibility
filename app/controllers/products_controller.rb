class ProductsController < ApplicationController
  def index
  end

  def show
  end

  def search
    query = Product.where("products.name ILIKE (?) OR brands.name ILIKE (?)", "%#{params[:search_term]}%", "%#{params[:search_term]}%")
    # optional type query param, can be a string or an array
    if params[:type].present?
      query = query.where(productable_type: params[:type])
    end
    if params[:exclude_types].present?
      query = query.where.not(productable_type: params[:exclude_types])
    end
    if params[:exclude_names].present?
      query = query.where.not(name: params[:exclude_names])
    end
    result = query.joins(:brand)
                  .limit(15)
                  .select('products.slug, products.name, brands.name AS brand_name')
                  .map { |product| { slug: product.slug, name: product.name, brand: product.brand_name } }
    render json: result
  end

  def fits
    @product = Product.friendly.includes(:image, :brand).find(params[:slug])
    @other_products = Product.where.not(productable_type: @product.productable_type).includes(:image, :brand)
    # all types except for the type of the product
    @search_types = %w[Stroller Seat Adapter] - [@product.productable_type]
    @other_type = @product.productable_type == "Stroller" ? "car seat" : "stroller"
  end

  def compatible
    @product_a = Product.friendly.find(params[:slug])
    @product_b = Product.friendly.find(params[:b_id])
    @adapter = @product_a.adapters.joins(:products).where(products: @product_b).first&.product
  end

  private

end
