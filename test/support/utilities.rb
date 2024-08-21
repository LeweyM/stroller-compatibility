module Utilities
  def create_product!(type: Stroller, **attributes)
    p = type.create!
    name = attributes[:name] || type.name + "_" + Faker::Commerce.product_name + "_" + SecureRandom.hex(4)
    brand = attributes[:brand] || Brand.create!(name: Faker::Company.name + "_" + SecureRandom.hex(4))
    Product.create!(name: name, brand: brand, productable: p, **attributes)
  end
end