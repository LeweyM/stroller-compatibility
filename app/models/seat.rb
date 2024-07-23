class Seat < ApplicationRecord
  belongs_to :brand
  has_one :product, :as => :productable, :dependent => :destroy

  def type
    "car seat"
  end
end
