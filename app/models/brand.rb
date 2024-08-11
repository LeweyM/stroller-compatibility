class Brand < ApplicationRecord
  has_many :products, dependent: :destroy

  def strollers
    products.where(productable_type: "Stroller")
  end

  def seats
    products.where(productable_type: "Seat")
  end

  def product_count
    products.count
  end
end
