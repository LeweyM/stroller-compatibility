module Utilities
  def create_product!(type: Stroller, **attributes)
    p = type.create!
    random_name_suffix = Faker::Commerce.product_name + "_" + SecureRandom.hex(4)
    name = attributes[:name] ? attributes[:name] + "_" + random_name_suffix : type.name + "_" + random_name_suffix
    brand = attributes[:brand] || Brand.create!(name: Faker::Company.name + "_" + SecureRandom.hex(4))
    Product.create!(brand: brand, productable: p, **attributes, name: name)
  end
end