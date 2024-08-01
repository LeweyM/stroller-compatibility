class Admin::ProductsController < Admin::BaseController
  def index
    @products = Product.all.order(:productable_type)
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


  def import
    file = params[:file]

    if file.nil?
      redirect_to admin_product_path, alert: "Please upload a valid CSV file."
      return
    end

    Product.import(file)

    redirect_to admin_products_path, notice: "Products imported successfully."
  end
end
