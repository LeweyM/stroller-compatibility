require 'zip'

class Admin::ProductsController < Admin::BaseController
  def index
    @brands = Brand.all
    @products = Product.includes(:product_adapters, :brand, :image, :tags, adapters: [:products, :product])

    if params[:search].present?
      @products = @products.where("products.name ILIKE ?", "%#{params[:search]}%")
    end

    if params[:type].present?
      @products = @products.where(productable_type: params[:type].capitalize)
    end

    if params[:brand].present?
      @products = @products.joins(:brand).where("brands.name ILIKE ?", "%#{params[:brand]}%")
    end

    @products = @products.order(:productable_type).to_a
  end

  def show
  end

  def new
    @product = Product.new
    @brands = Brand.all
  end

  def create
    @product = Product.new(product_params)
    productable = case product_params[:productable_type]
                  when "Stroller" then Stroller.new
                  when "Seat" then Seat.new
                  when "Adapter" then Adapter.new
                  else raise "Invalid product type"
                  end
    @product.productable = productable
    @product.brand = Brand.find(params[:product][:brand])
    if @product.save
      redirect_to edit_admin_product_path(@product), notice: "Product was successfully created."
      return
    end

    flash[:error] = "Something went wrong when creating the product"
    render :new
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
  def check_url
    @product = Product.friendly.find(params[:product_id])
    product_url = @product.url
    response = HTTParty.get(product_url, follow_redirects: false)

    render json: {
      response_status: response.code,
      redirect_to: response.headers['location'] || nil
    }
  end

  def generate_url
    @product = Product.friendly.find(params[:id])
    client = GoogleApiService.new
    begin
      results = client.url_search(@product)
      @product.url = results.first["link"]
      @product.save
      flash[:success] = "URL for #{@product.name} updated."
      redirect_to edit_admin_product_path(@product)
    rescue => e
      logger.error "Failed to find URL: #{e.message}"
      flash[:error] = "No URL found for #{@product.name}."
      redirect_to edit_admin_product_path(@product)
      return
    end
  end

  def import
    files = params[:files].reject(&:blank?)

    begin
      files.each { |file|
        Product.import(file)
      }
      redirect_to admin_products_path, notice: "Products imported successfully."
    rescue StandardError => e
      flash[:error] = "Error importing products: #{e.message}"
      redirect_to admin_products_path

    end
  end

  def export
    send_data(Product.export_all, filename: "product_export_#{Date.today}.csv", type: "text/csv")
  end

  def export_compatible
    send_data(Product.export_compatible, filename: "compatible_export_#{Date.today}.csv", type: "text/csv")
  end

  def export_tags
    send_data(Product.export_tags, filename: "tags_export_#{Date.today}.csv", type: "text/csv")
  end

  def export_all
    products_csv = Product.export_all
    compatibility_csv = Product.export_compatible
    tags_csv = Product.export_tags
    brands_csv = Brand.export_to_csv

    compressed_filestream = Zip::OutputStream.write_buffer do |zos|
      zos.put_next_entry("product_export_#{Date.today}.csv")
      zos.write products_csv
      zos.put_next_entry("compatibility_export_#{Date.today}.csv")
      zos.write compatibility_csv
      zos.put_next_entry("tags_export_#{Date.today}.csv")
      zos.write tags_csv
      zos.put_next_entry("brands_export_#{Date.today}.csv")
      zos.write brands_csv
    end

    compressed_filestream.rewind
    send_data compressed_filestream.read, filename: "all_exports_#{Date.today}.zip"
  end

  def update
    @product = Product.friendly.find(params[:id])
    if @product.update(product_params)
      has_image_to_update = !params[:product][:image_url].empty? ||
        !params[:product][:image_alt_text].empty? ||
        !params[:product][:image_attribution_url].empty? ||
        !params[:product][:image_attribution_text].empty?
      if has_image_to_update
        update_or_create_image(@product, params[:product])
      end
      flash[:notice] = 'Product was successfully updated.'
    else
      flash[:error] = 'Something went wrong when updating the product'
    end
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.action(:refresh, "") }
      format.html { render :edit }
    end
  end

  private

  def product_params
    params.require(:product).permit(:name, :brand_id, :productable_type, :url, tag_ids: [])
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
