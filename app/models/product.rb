class Product < ApplicationRecord
  require 'csv'

  extend FriendlyId

  belongs_to :productable, polymorphic: true, dependent: :destroy
  belongs_to :brand

  has_many :compatible_links_as_product_a, class_name: 'CompatibleLink', foreign_key: :product_a_id
  has_many :compatible_links_as_product_b, class_name: 'CompatibleLink', foreign_key: :product_b_id
  has_many :compatible_links_as_adapter, class_name: 'CompatibleLink', foreign_key: :adapter_id

  has_many :compatible_products_as_a, through: :compatible_links_as_product_a, source: :product_b
  has_many :compatible_products_as_b, through: :compatible_links_as_product_b, source: :product_a

  has_one :image, dependent: :destroy

  friendly_id :name, use: :slugged

  def image_or_default
    if has_image?
      image
    else
      default_image
    end
  end

  def default_image
    case productable_type
    when "Stroller" then Stroller::default_image
    when "Seat" then Seat::default_image
    else Image.new(
      :attribution_url => "https://www.freepik.com/free-vector/illustration-jigsaw-icon_2606569.htm#fromView=search&page=1&position=0&uuid=37efe3f8-4e5e-4a3d-b213-2c6af1ce2cb1",
      :url => ActionController::Base.helpers.asset_path('puzzle.jpg'),
      :alt_text => "Adapter",
      :attribution_text => "Image by rawpixel.com on Freepik"
    )
    end
  end

  def image_attribution_required?
    image_or_default.attribution_required?
  end

  def compatible_products
    Product.where(id: compatible_products_as_a.pluck(:id) + compatible_products_as_b.pluck(:id))
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  def self.import(file)
    filename = file.original_filename
    raise "Invalid file type. Must be CSV." unless File.extname(filename).downcase == '.csv'
    #   delegate to private methods based on filename ending  case file
    end_of_filename = filename.split('-').last.downcase.chomp('.csv')
    case end_of_filename
    when "strollers" then import_products(file)
    when "seats" then import_products(file)
    when "matrix" then import_matrix(file)
    else
      allowed_import_file_endings = %w[strollers seats matrix]
      raise "Unknown filename '#{filename}'. Filename must end with one of #{allowed_import_file_endings.map { |ending| "'#{-ending}.csv'" }.join(', ')}"
    end
  end

  private

  # import a cvs data
  # format: first column is a list of strollers, except first cell
  # first row is a list of car seats, except first cell
  # rest of table is compatiblity. If there is an x, the two products are compatible
  # should expect the products to already exist, otherwise error
  def self.import_matrix(file)
    csv_text = File.read(file)
    csv = CSV.parse(csv_text, headers: true)

    seat_and_y_index = csv.headers[1..-1].each_with_index.map { |header, index| [header, index] }[1..-1]
    stroller_and_x_index = csv.each_with_index.map { |row, index| [row[0], index] }[1..-1]

    # compatibility exists if not nil at intersection
    seat_and_y_index.each do |seat_name, y|
      stroller_and_x_index.each do |stroller_name, x|
        # if either seat or stroller don't exist, error
        stroller = Product.find_by(name: stroller_name)
        seat = Product.find_by(name: seat_name)
        if stroller.nil?
          raise "Error: stroller #{stroller_name} not found"
        end
        if seat.nil?
          raise "Error: seat #{seat_name} not found"
        end

        unless csv[seat_name][x].nil?
          CompatibleLink.create!(product_a: stroller, product_b: seat)
        end
      end
    end
  end
  private_class_method :import_matrix

  # this expects csv file where each row is a product
  # with the following columns:
  # type,brand,name,link,image_url
  def self.import_products(file)
    csv_text = File.read(file)
    csv = CSV.parse(csv_text, headers: true)
    csv.each do |row|
      pp row
      type = row[0]
      brand_name = row[1]
      name = row[2]
      link = row[3]
      image_url = row[4]

      brand = Brand.find_by(name: brand_name)
      if brand.nil?
        brand = Brand.create!(name: brand_name)
      end
      product = Product.find_by(name: name)
      if product.nil?
        productable = (type.downcase == 'seat') ? Seat.create! : Stroller.create!

        product = Product.create!(
          name: name,
          link: link,
          brand: brand,
          productable: productable
        )
        image = Image.find_by(url: image_url)
        if image.nil?
          image = Image.create!(
            :url => image_url,
            product: product
          )
          image.save!
        end
        product.save!
      end
    end
  end
  private_class_method :import_products

  def has_image?
    image.present?
  end
end
