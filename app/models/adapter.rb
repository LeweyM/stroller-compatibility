class Adapter < ApplicationRecord
  has_one :product, :as => :productable, :dependent => :destroy

  has_many :product_adapters
  has_many :products, through: :product_adapters

  scope :by_tags, ->(tags) {  left_joins(product: [:tags]).where('tags': { id: tags.ids }).select("*") }

  def compatible_products
    Product.compatible_with_adapter(self)
  end
end
