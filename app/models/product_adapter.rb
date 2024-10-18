class ProductAdapter < ApplicationRecord
  belongs_to :product
  belongs_to :adapter

  # @return [Hash{Symbol->Unknown}]
  def serialize
    {
      product: product.serialize,
      adapter: adapter.product.serialize
    }
  end
end