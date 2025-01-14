class Product < ApplicationRecord
  require 'csv'

  extend FriendlyId

  belongs_to :productable, polymorphic: true, dependent: :destroy
  belongs_to :brand

  has_many :product_adapters
  has_many :adapters, through: :product_adapters

  has_and_belongs_to_many :tags

  has_one :image, dependent: :destroy

  friendly_id :name, use: :slugged

  validates :name, presence: true

  scope :by_tag_ids, ->(tag_ids) {
    where(id: ProductsTag.where(tag_id: tag_ids).select(:product_id))
  }

  scope :by_adapter, ->(adapter) {
    adapter.products
  }

  scope :compatible_with_adapter, ->(adapter) {
    adapter_products = Product.by_adapter(adapter)
    tag_products = Product.by_tag_ids(adapter.product.tags.ids)

    Product.where(id: adapter_products.select(:id)).or(Product.where(id: tag_products.select(:id)))
           .where.not(productable_type: 'Adapter')
  }

  def combined_adapters
    if productable_type == 'Adapter'
      return [self.productable]
    end
    Adapter.where(id: direct_adapters_ids).or(Adapter.where(id: tagged_adapter_ids))
  end

  def direct_adapters_ids
    adapters.ids
  end

  def tagged_adapter_ids
    Adapter.by_tags(tags).ids
  end

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

  def serialize
    as_json
      .merge('brand' => brand.as_json)
      .merge('image' => image_or_default.as_json)
      .merge('tags' => tags.map(&:serializable_hash))
  end

  def image_attribution_required?
    image_or_default.attribution_required?
  end

  def compatible_products
    compatible_products_by_adapter.values.flatten.uniq
  end

  # get all products linked to this product, grouped by the adapter
  def compatible_products_by_adapter
    CompatibleProduct.for_product(self)
                     .group_by(&:adapter)
                     .transform_keys(&:slug)
  end

  def should_generate_new_friendly_id?
    name_changed?
  end

  def is_linked_to?(adapter_product)
    raise "Can only check if linked to an adapter" if adapter_product.productable_type != 'Adapter'
    product_adapters.exists?(adapter: adapter_product.productable)
  end

  def link!(adapter_product)
    validate_linkable(adapter_product)

    adapter = adapter_product.productable
    adapter.products << self
  end

  def unlink!(adapter_product)
    validate_linkable(adapter_product)
    raise "Product is not linked to #{adapter_product.name}" unless is_linked_to?(adapter_product)
    adapter = adapter_product.productable
    adapter.products.delete(self)
  end

  def add_tag(tag)
    # Check if the tag is already associated with the product
    unless self.tags.include?(tag)
      self.tags << tag
    end
  end

  def remove_tag(tag)
    # Check if the tag is associated with the product
    if self.tags.include?(tag)
      self.tags.delete(tag)
    end
  end

  def has_image?
    image.present?
  end

  private

  def validate_linkable(other_product)
    raise "Cannot link a product to itself" if self == other_product
    raise "Can only link a product to an adapter" if other_product.productable_type != 'Adapter'
  end

  def self.sort_rows(rows, headers, sort_headers)
    header_indexes = sort_headers.map { |header| headers.index(header) }
    rows.sort_by do |row|
      fields = row.split(",")
      header_indexes.map { |index| fields[index] }
    end
  end

  def self.export_all
    CSV.generate(force_quotes: true) do |csv|
      csv << %w[type brand name url image_url]
      all.includes(:brand).order('brands.name', :productable_type, :name).each do |product|
        csv << [
          product.productable_type.capitalize,
          product.brand.name,
          product.name,
          product.url,
          product.image&.url
        ]
      end
    end
  end

  def self.export_compatible
    CSV.generate(force_quotes: true) do |csv|
      Adapter.all.each do |adapter|
        products = adapter.products.all
        strollers = products.filter { |product| product.productable_type == "Stroller" }.map(&:name)
        seats = products.filter { |product| product.productable_type == "Seat" }.map(&:name)

        csv << strollers.uniq
        csv << seats.uniq
        csv << [adapter.product.name]
      end
    end
  end

  def self.export_tags
    CSV.generate(force_quotes: true) do |csv|
      tags = Tag.all
      csv << tags.map(&:brand).map(&:name)
      csv << tags.pluck(:label)
      Tag.all
         .map { |tag| tag.products.map(&:slug) }
         .reduce(&:zip)
         .each { |row| csv << [row].flatten }
    end
  end

  def self.import_compatibility(file)
    # expects a csv file with 3 rows, no headers
    # row 0: list of strollers
    # row 1: list of car seats
    # row 2: (optional) adapter product name
    # any products mentioned should already exist, or an exception should be raised and no db changes made.
    csv_text = File.read(file)
    csv = CSV.parse(csv_text, headers: false)

    csv.each_slice(3) do |batch|
      # Ensure there are exactly 3 rows in the batch (strollers, seats, adapter)
      next unless batch.size == 3

      strollers = batch[0].filter { |s| not s.nil? }
                          .map { |name| Product.find_by!(name: name, productable_type: "Stroller") }
      seats = batch[1].filter { |s| not s.nil? }
                      .map { |name| Product.find_by!(name: name, productable_type: "Seat") }
      adapter_name = batch[2].first unless batch[2].first.nil?
      adapter = Product.find_by!(name: adapter_name, productable_type: "Adapter")

      strollers.each do |product|
        product.link!(adapter) unless product.is_linked_to? adapter
      end
      seats.each do |product|
        product.link!(adapter) unless product.is_linked_to? adapter
      end
    end
  end

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
          raise 'TODO: Implement linking without an adapter'
        end
      end
    end
  end

  # this expects csv file where each row is a product
  # with the following columns:
  # type,brand,name,link,image_url
  # @param [File] file CSV file with product import data
  # @return [Integer] Count of newly created product records
  def self.import_products(file)
    csv_text = File.read(file)
    csv = CSV.parse(csv_text, headers: true)
    count = 0

    Product.transaction do
      csv.each do |row|
        type = row[0]
        brand_name = row[1]
        name = row[2]
        link = row[3]
        image_url = row[4]

        brand = Brand.find_by(name: brand_name)
        if brand.nil?
          raise "brand '#{brand_name}' not recognized"
        end
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
            url: link,
            brand: brand,
            productable: productable,
            image: image_url ? Image.create_or_find_by(:url => image_url) : nil
          )
          count += 1
        end
      end
    end
    count
  end

end

