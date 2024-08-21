class Admin::BrandsController < Admin::BaseController
  def index
    brands_with_counts, total_products = Brand.ordered_by_product_count_with_totals

    @brands = brands_with_counts
    @total_product_count = total_products
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

  def export
    headers = "name,website"
    rows = Brand.all.map do |brand|
      "#{brand.name},#{brand.website}"
    end
    send_data headers + "\n" + rows.join("\n"), filename: "brands_#{Date.today}.csv", type: "text/csv"
  end

  private

  def brand_params
    params.require(:brand).permit(:name, :website)
  end
end
