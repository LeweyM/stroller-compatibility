class Stroller < ApplicationRecord
  belongs_to :brand
  has_one :product, :as => :productable, :dependent => :destroy

  def type
    "stroller"
  end
end
