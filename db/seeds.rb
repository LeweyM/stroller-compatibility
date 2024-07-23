# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# brands
["maxicosi", "lovecare"].each do |brand_name|
  Brand.find_or_create_by!(name: brand_name)
end

# stroller models for maxicosi
["maxicosi 120", "maxicosi 140", "maxicosi 160", "maxicosi 180", "maxicosi 200"].each do |model_name|
  b = Brand.find_by(name: "maxicosi")
  s = Stroller.find_or_create_by!(brand_id: b.id, name: model_name)
  Product.create!(productable: s, name: model_name, link: "https://www.maxicosi.com/#{model_name}", brand: b)
end

# stroller models for lovecare
["lovecare grande", "lovecare pequeño", "lovecare 120", "lovecare 140", "lovecare 160", "lovecare 180", "lovecare 200"].each do |model_name|
  b = Brand.find_by(name: "lovecare")
  s = Stroller.find_or_create_by!(brand_id: Brand.find_by(name: "lovecare").id, name: model_name)
  Product.create!(productable: s, name: model_name, link: "https://www.lovecare.com/#{model_name}", brand: b)
end

# seat models for maxicosi
["pebble", "cushion", "cushion with pebble", "cushion with pebble and wheel", "wheel", "wheel with pebble", "wheel with pebble and cushion", "wheel with cushion", "wheel with cushion and pebble"].each do |model_name|
  b = Brand.find_by(name: "maxicosi")
  s = Seat.find_or_create_by!(brand_id: Brand.find_by(name: "maxicosi").id, name: model_name, link: "https://www.maxicosi.com/#{model_name}")
  Product.create!(productable: s, name: model_name, link: "https://www.maxicosi.com/#{model_name}", brand: b)
end

# seat models for lovecare
["protectron", "xl", "xl with protectron", "xl with protectron and wheel", "xl with wheel", "xl with wheel and protectron", "xl with wheel and cushion", "xl with cushion", "xl with cushion and protectron"].each do |model_name|
  b = Brand.find_by(name: "lovecare")
  s = Seat.find_or_create_by!(brand_id: Brand.find_by(name: "lovecare").id, name: model_name, link: "https://www.lovecare.com/#{model_name}")
  Product.create!(productable: s, name: model_name, link: "https://www.lovecare.com/#{model_name}", brand: b)
end
