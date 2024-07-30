class Stroller < ApplicationRecord
  has_one :product, :as => :productable, :dependent => :destroy

  def type
    "stroller"
  end

  def self::default_image
    Image.new(
      :attribution_url => "https://www.freepik.com/free-vector/mothers-fathers-with-various-baby-carriages-flat-set-isolated-vector-illustration_64993775.htm#fromView=search&page=1&position=5&uuid=32ccb005-e4f3-4be0-b2a2-299d3871751f",
      :url => ActionController::Base.helpers.asset_path('mom-stroller.jpg'),
      :alt_text => "Stroller",
      :attribution_text => "Image by macrovector on Freepik"
    )
  end
end
