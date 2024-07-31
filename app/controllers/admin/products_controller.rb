class Admin::ProductsController < Admin::BaseController
  def index
    @products = Product.all
  end

  def show
  end

  def new
  end

  def edit
  end

  def destroy
    @product = Product.friendly.find(params[:id])
    @product.destroy
    redirect_to admin_products_path
  end
end
