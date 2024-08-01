class Product < ApplicationRecord
  require 'csv'

  extend FriendlyId

  belongs_to :productable, polymorphic: true
  belongs_to :brand

  has_many :compatible_links_as_product_a, class_name: 'CompatibleLink', foreign_key: :product_a_id
  has_many :compatible_links_as_product_b, class_name: 'CompatibleLink', foreign_key: :product_b_id
  has_many :compatible_links_as_adapter, class_name: 'CompatibleLink', foreign_key: :adapter_id

  has_many :compatible_products_as_a, through: :compatible_links_as_product_a, source: :product_b
  has_many :compatible_products_as_b, through: :compatible_links_as_product_b, source: :product_a

  has_one :image

  friendly_id :name, use: :slugged

  def image_or_default
    image if has_image?
    default_image
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

  # import a cvs data
  # format: first column is a list of strollers, except first cell
  # first row is a list of car seats, except first cell
  # rest of table is compatiblity. If there is an x, the two products are compatible
  # should expect the products to already exist, otherwise error
  def self.import(file)
    csv_text = File.read(file)
    csv = CSV.parse(csv_text, headers: true)

    seat_and_y_index = csv.headers[1..-1].each_with_index.map { |header, index| [header, index] }[1..-1]
    stroller_and_x_index = csv.each_with_index.map { |row, index| [row[0], index] }[1..-1]

    # for now, create the brand
    brand = Brand.create_or_find_by(name: "Maxicosi")

    # compatibility exists if not nil at intersection
    seat_and_y_index.each do | seat_name, y |
      stroller_and_x_index.each do | stroller_name, x |
        print "\n\n\n"
        print "creating or finding '#{stroller_name}' and '#{seat_name}'"
        print "\n\n\n"
        # for now, create the products
        seat = Seat.find_by_name(seat_name)
        if seat.nil?
          seat = Seat.create!(name: seat_name)
        end

        stroller = Stroller.find_by_name(stroller_name)
        if stroller.nil?
          stroller = Stroller.create!(name: stroller_name)
        end

        stroller_product = Product.create_or_find_by!(productable: stroller, brand: brand, name: stroller.name)
        seat_product = Product.create_or_find_by!(productable: seat, brand: brand, name: seat.name)

        unless csv[seat_name][x].nil?
          print "\n\n\n"
          print " compatible! "
          print "\n\n\n"

          CompatibleLink.create!(product_a: stroller_product, product_b: seat_product)
        end
      end
    end
  end

  private

  def has_image?
    image.present?
  end
end
