class Product < ApplicationRecord
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

  private

  def has_image?
    image.present?
  end
end
