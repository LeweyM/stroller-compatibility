class ProductAdapter < ApplicationRecord
  belongs_to :product
  belongs_to :adapter
end