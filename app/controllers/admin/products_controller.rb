class Admin::ProductsController < Admin::BaseController
  def index
    @products = Product.joins(:brand).all.order(:productable_type)

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
    @next_product = Product.where("id > ?", @product.id).first
    @previous_product = Product.where("id < ?", @product.id).last
  end

  def destroy
    @product = Product.friendly.find(params[:id])
    @product.destroy
    redirect_to admin_products_path
  end

  # make a http request against the product link to check if it's a valid link
  def check_link
    @product = Product.friendly.find(params[:product_id])
    product_link = @product.link
    response = HTTParty.get(product_link, follow_redirects: false)

    render json: {
      response_status: response.code,
      redirect_to: response.headers['location'] || nil
    }
  end

  def import
    file = params[:file]

    begin
      Product.import(file)
      redirect_to admin_products_path, notice: "Products imported successfully."
    rescue StandardError => e
      flash[:error] = "Error importing products: #{e.message}"
      redirect_to admin_products_path

    end
  end

  def export
    headers = "type,brand,name,url,image_url"
    rows = Product.all.map do |product|
      "#{product.productable_type.capitalize},#{product.brand.name},#{product.name},#{product.link},#{product.image&.url}"
    end
    rows = rows.sort_by { |row| [row.split(",")[1], row.split(",")[0]] }
    data = headers + "\n" + rows.join("\n")
    send_data(data, filename: "product_export_#{Date.today}.csv", type: "text/csv")
  end

  def export_compatible
    # for each adapter, 3 rows. 1st row, a list of strollers, 2nd row a list of seats, 3rd row a single cell with adapter name
    adapters = CompatibleLink.all.group_by(&:adapter)
    sets = []
    adapters.each do |adapter, links|
      strollers_a = links.select { |link| link.product_a.productable_type == "Stroller" }
      strollers_b = links.select { |link| link.product_b.productable_type == "Stroller" }
      strollers = strollers_a.map { |link| link.product_a.name } + strollers_b.map { |link| link.product_b.name }

      seats_a = links.select { |link| link.product_a.productable_type == "Seat" }
      seats_b = links.select { |link| link.product_b.productable_type == "Seat" }
      seats = seats_a.map { |link| link.product_a.name } + seats_b.map { |link| link.product_b.name }

      row1 = strollers.uniq.join(",")
      row2 = seats.uniq.join(",")
      row3 = adapter.name
      sets << [row1, row2, row3]
    end

    send_data(sets.join("\n"), filename: "compatible_export_#{Date.today}.csv", type: "text/csv")
  end

  def update
    @product = Product.friendly.find(params[:id])
    pp product_params
    if @product.update(product_params)
          if params[:product][:image_url] || params[:product][:image_alt_text] || params[:product][:image_attribution_url] || params[:product][:image_attribution_text]
            update_or_create_image(@product, params[:product])
          end
          redirect_to admin_products_path, notice: 'Product was successfully updated.'    else
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
