class Admin::BrandsController < Admin::BaseController
  def index
    @brands = Brand.all
    @total_product_count = @brands.reduce(0) { |sum, brand| sum + brand.product_count }
  end

  def edit
    @brand = Brand.find(params[:id])
  end

  def update
    @brand = Brand.find(params[:id])
    @brand.update(brand_params)
    redirect_to admin_brands_path, notice: 'Brand was successfully updated.'
  end

  def destroy
    @brand = Brand.find(params[:id])
    @brand.destroy

    redirect_to admin_brands_path
  end

  private

  def brand_params
    params.require(:brand).permit(:name, :website)
  end
end
