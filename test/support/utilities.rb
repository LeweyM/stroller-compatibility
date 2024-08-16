module Utilities
  def create_product!(type: Stroller, **attributes)
    p = type.create!
    name = attributes[:name] || type.name + "_" + Faker::Commerce.product_name
    brand = attributes[:brand] || brands(:maxicosi)
    Product.create!(name: name, brand: brand, productable: p, **attributes)
  end
end