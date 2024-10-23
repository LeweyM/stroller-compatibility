class Adapter < ApplicationRecord
  has_one :product, :as => :productable, :dependent => :destroy

  has_many :product_adapters
  has_many :products, through: :product_adapters

  scope :by_tags, ->(tags) { left_joins(product: [:tags]).where('tags': { id: tags.ids }).select("*") }

  def compatible_products
    Product.compatible_with_adapter(self)
  end

  def compatible_products_via_direct
    adapter_products = Product.by_adapter(self)

    Product
      .includes(:image, :brand)
      .where(id: adapter_products.select(:id))
      .where.not(productable_type: 'Adapter')
  end

  def compatible_products_via_tag
    tag_products = Product.by_tag_ids(self.product.tags.ids)

    Product
      .includes(:image, :brand)
      .where(id: tag_products.select(:id))
      .where.not(productable_type: 'Adapter')
  end
end
