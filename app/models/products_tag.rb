class ProductsTag < ApplicationRecord
  belongs_to :product
  belongs_to :tag

  validates :product_id, presence: true
  validates :tag_id, presence: true
  validates :product_id, uniqueness: { scope: :tag_id }

end
