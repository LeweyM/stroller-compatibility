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

    # Create image if image_url is present
    if params[:image_url].present?
      @product.build_image(
        url: params[:image_url]
      )
    end

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
    counts = {}

    # sort files so brands is first
    files = files.sort_by { |file|
      case file.original_filename.split('_').first.downcase.chomp('.csv')
      when 'brands' then 1
      when 'products' then 2
      else 3
      end
    }

    begin
      files.each { |file|
        filename = file.original_filename
        raise "Invalid file type. Must be CSV." unless File.extname(filename).downcase == '.csv'
        #   delegate to private methods based on filename ending  case file
        start_of_filename = filename.split('_').first.downcase.chomp('.csv')
        case start_of_filename
        when "product" then counts[:products_added_count] = Product.import(file)
        when "matrix" then Product.import(file)
        when "compatible" then Product.import(file)
        when "tags" then counts[:tags_added_count] = Product.import(file)
        when "brands" then counts[:brands_added_count] = Brand.import(file)
        else
          allowed_import_file_endings = %w[product matrix compatible tags brands]
          raise "Unknown filename '#{filename}'. Filename must begin with one of #{allowed_import_file_endings.join(', ')}"
        end
      }
      redirect_to admin_products_path, notice: import_success_message(counts)
    rescue StandardError => e
      flash[:error] = "Import Error: #{e.message}"
      redirect_to admin_products_path, error: :unprocessable_entity
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
      zos.put_next_entry("compatible_export_#{Date.today}.csv")
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

  # @param [Integer] count The count to format
  # @param [String] singular_label The singular form of the label to use
  # @return [String, nil] Returns a formatted string with count and label, or nil if count is nil
  def format_count(count, singular_label)
    singular_label = singular_label.singularize
    if count.present? && count > 0
      "#{count} #{count > 1 ? singular_label.pluralize : singular_label}"
    else
      nil
    end
  end

  # @return [String]
  # @param [Object] counts
  def import_success_message(counts)
    [
      format_count(counts[:brands_added_count], "Brand"),
      format_count(counts[:products_added_count], "Product"),
      format_count(counts[:links_added_count], "Product Link"),
      format_count(counts[:tags_added_count], "Tag"),
    ].compact.join(", ") + " imported successfully"
  end

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
