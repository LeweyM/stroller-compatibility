# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

# stroller brands
["maxicosi", "lovecare"].each do |brand_name|
  Brand.find_or_create_by!(name: brand_name, website: "https://www.#{brand_name}.com/")
end

# stroller models for maxicosi
["maxicosi 120", "maxicosi 140", "maxicosi 160", "maxicosi 180", "maxicosi 200"].each do |model_name|
  Stroller.find_or_create_by!(brand_id: Brand.find_by(name: "maxicosi").id, name: model_name)
end

# stroller models for lovecare
["lovecare grande", "lovecare pequeño", "lovecare 120", "lovecare 140", "lovecare 160", "lovecare 180", "lovecare 200"].each do |model_name|
  Stroller.find_or_create_by!(brand_id: Brand.find_by(name: "lovecare").id, name: model_name)
end

# seat models for maxicosi
["pebble", "cushion", "cushion with pebble", "cushion with pebble and wheel", "wheel", "wheel with pebble", "wheel with pebble and cushion", "wheel with cushion", "wheel with cushion and pebble"].each do |model_name|
  Seat.find_or_create_by!(brand_id: Brand.find_by(name: "maxicosi").id, name: model_name, link: "https://www.maxicosi.com/#{model_name}")
end

# seat models for lovecare
["protectron", "xl", "xl with protectron", "xl with protectron and wheel", "xl with wheel", "xl with wheel and protectron", "xl with wheel and cushion", "xl with cushion", "xl with cushion and protectron"].each do |model_name|
  Seat.find_or_create_by!(brand_id: Brand.find_by(name: "lovecare").id, name: model_name, link: "https://www.lovecare.com/#{model_name}")
end
