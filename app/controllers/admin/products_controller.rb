class Admin::ProductsController < Admin::BaseController
  def index
    @products = Product.joins(:brand).all.order(:productable_type)

    pp params
    if params[:search].present?
      @products = @products.where("name LIKE ? OR description LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%")
    end

    if params[:type].present?
      @products = @products.where(productable_type: params[:type].capitalize)
    end

    if params[:brand].present?
      @products = @products.joins(:brand).where(brands: { name: params[:brand].capitalize })
    end
  end

  def show
  end

  def new
  end

  def edit
    @product = Product.friendly.find(params[:id])
  end
  def destroy
    @product = Product.friendly.find(params[:id])
    @product.destroy
    redirect_to admin_products_path
  end

  def import_matrix
    file = params[:file]

    if file.nil?
      redirect_to admin_products_path, alert: "Please upload a valid CSV file."
      return
    end

    Product.import_matrix(file)

    redirect_to admin_products_path, notice: "Products imported successfully."
  end

  def import
    file = params[:file]

    if file.nil?
      redirect_to admin_products_path, alert: "Please upload a valid CSV file."
      return
    end

    Product.import_products(file)

    redirect_to admin_products_path, notice: "Products imported successfully."
  end

  def update
    @product = Product.friendly.find(params[:id])
    if @product.update(product_params)
      update_or_create_image(@product, params[:product])
      redirect_to admin_products_path, notice: 'Product was successfully updated.'
    else
      render :edit
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :brand_id, :productable_type, :link)
  end

  def update_or_create_image(product, image_params)
    if product.image
      product.image.update(
        url: image_params[:image_url],
        alt_text: image_params[:image_alt_text],
        attribution_url: image_params[:image_attribution_url],
        attribution_text: image_params[:image_attribution_text]
      )
    else
      product.create_image(
        url: image_params[:image_url],
        alt_text: image_params[:image_alt_text],
        attribution_url: image_params[:image_attribution_url],
        attribution_text: image_params[:image_attribution_text]
      )
    end
  end
end
