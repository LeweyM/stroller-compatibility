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
    when "strollers", "seats", "adapters" then import_products(file)
    when "matrix" then import_matrix(file)
    when "compatibility" then import_compatibility(file)
    else
      allowed_import_file_endings = %w[strollers seats adapters matrix compatibility]
      raise "Unknown filename '#{filename}'. Filename must end with one of #{allowed_import_file_endings.map { |ending| "'#{-ending}.csv'" }.join(', ')}"
    end
  end

  def add_compatible_product(other_product, adapter = nil)
    return if self == other_product

    existing_link = CompatibleLink.find_by(
      product_a: [self, other_product],
      product_b: [self, other_product]
    )

    unless existing_link
      CompatibleLink.create!(
        product_a: self,
        product_b: other_product,
        adapter: adapter
      )
    end
  end

  private

  def self.import_compatibility(file)
    # expects a csv file with 3 rows, no headers
    # row 0: list of strollers
    # row 1: list of car seats
    # row 2: (optional) adapter product name
    # any products mentioned should already exist, or an exception should be raised and no db changes made.
    csv_text = File.read(file)
    csv = CSV.parse(csv_text, headers: false)
    strollers = csv[0].filter { |s| not s.nil? }
                      .map { |name| Product.find_by!(name: name, productable_type: "Stroller") }
    seats = csv[1].filter { |s| not s.nil? }
                  .map { |name| Product.find_by!(name: name, productable_type: "Seat") }
    adapter_name = csv[2].first unless csv[2].first.nil?
    adapter = Product.find_by!(name: adapter_name, productable_type: "Adapter")

    strollers.each do |product|
      seats.each do |other_product|
        product.add_compatible_product(other_product, adapter)
      end
    end
  end

  private_class_method :import_compatibility

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
      type = row[0]
      brand_name = row[1]
      name = row[2]
      link = row[3]
      image_url = row[4]

      brand = Brand.find_or_create_by!(name: brand_name)
      product = Product.find_by(name: name)
      if product.nil?
        productable = case type.downcase
                      when 'seat'
                        Seat.create!
                      when 'stroller'
                        Stroller.create!
                      when 'adapter'
                        Adapter.create!
                      else
                        raise "Unknown product type: #{type}"
                      end

        Product.create!(
          name: name,
          link: link,
          brand: brand,
          productable: productable,
          image: image_url ? Image.create_or_find_by(:url => image_url) : nil
        )
      end
    end
  end

  private_class_method :import_products

  def has_image?
    image.present?
  end
end
