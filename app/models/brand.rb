class Brand < ApplicationRecord
  has_many :products, dependent: :destroy

  def strollers
    products.where(productable_type: "Stroller")
  end

  def seats
    products.where(productable_type: "Seat")
  end
end
