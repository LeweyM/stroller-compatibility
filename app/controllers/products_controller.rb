class ProductsController < ApplicationController
  def index
  end

  def show
  end

  def search
    page_size = 15
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
    offset = params[:page].present? ? params[:page].to_i * page_size : 0

    result = query.joins(:brand)
                  .offset(offset)
                  .limit(page_size)
                  .select('products.slug, products.name, brands.name AS brand_name')
                  .order('brands.name ASC, products.slug ASC')
                  .map { |product| { slug: product.slug, name: product.name, brand: product.brand_name } }
    render json: result
  end

  def fits
    @product = Product.friendly.includes(:image, :brand).find(params[:slug])
    @other_products = Product.where.not(productable_type: @product.productable_type).includes(:image, :brand)
    # all types except for the type of the product
    @search_types = %w[Stroller Seat] - [@product.productable_type]
    @other_type = @product.productable_type == "Stroller" ? "car seat" : "stroller"
  end

  def compatible
    @product_a = Product.left_joins(:image, :brand).includes(:image, :brand).friendly.find(params[:slug])
    @product_b = Product.left_joins(:image, :brand).includes(:image, :brand).friendly.find(params[:b_id])
    result = CompatibleProduct.for_product(@product_a).filter { |cp| cp.product.id == @product_b.id }
    @is_compatible = result.any?
    @adapter = result.first&.adapter
  end

  private

end
