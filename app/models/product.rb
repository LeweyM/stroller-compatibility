class Product < ApplicationRecord
  extend FriendlyId

  belongs_to :productable, polymorphic: true
  belongs_to :brand

  has_many :compatible_links_as_product_a, class_name: 'CompatibleLink', foreign_key: :product_a_id
  has_many :compatible_links_as_product_b, class_name: 'CompatibleLink', foreign_key: :product_b_id
  has_many :compatible_links_as_adapter, class_name: 'CompatibleLink', foreign_key: :adapter_id

  friendly_id :name, use: :slugged

  def should_generate_new_friendly_id?
    name_changed?
  end
end
