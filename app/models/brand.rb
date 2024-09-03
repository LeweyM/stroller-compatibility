class Brand < ApplicationRecord
  has_many :products, dependent: :destroy
  has_many :tags, dependent: :destroy

  def self.ordered_by_product_count_with_totals
    brands_with_counts = Brand.left_joins(:products)
                              .includes(:tags)
                              .select('brands.*, COUNT(products.id) AS products_count')
                              .group('brands.id')
                              .order('COUNT(products.id) DESC')

    return brands_with_counts, brands_with_counts.sum(&:products_count)
  end

  def strollers
    products.where(productable_type: "Stroller")
  end

  def seats
    products.where(productable_type: "Seat")
  end
end
