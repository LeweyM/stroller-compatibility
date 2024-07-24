class CompatibleLink < ApplicationRecord
  belongs_to :product_a, class_name: "Product"
  belongs_to :product_b, class_name: "Product"
  belongs_to :adapter, class_name: "Product", optional: true
end
