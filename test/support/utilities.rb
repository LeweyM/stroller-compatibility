module Utilities
  def create_product!(type: Stroller, fix_name: false, **attributes)
    p = type.create!
    if fix_name && attributes[:name]
      name = attributes[:name]
    else
      random_name_suffix = Faker::Commerce.product_name + "_" + SecureRandom.hex(4)
      name = attributes[:name] ? attributes[:name] + "_" + random_name_suffix : type.name + "_" + random_name_suffix
    end
    brand = attributes[:brand] || Brand.create!(name: Faker::Company.name + "_" + SecureRandom.hex(4))
    Product.create!(brand: brand, productable: p, **attributes, name: name)
  end
end