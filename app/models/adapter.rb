class Adapter < ApplicationRecord
  has_one :product, :as => :productable, :dependent => :destroy

  has_many :product_adapters
  has_many :products, through: :product_adapters
end
