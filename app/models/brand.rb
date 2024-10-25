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

  # @return [String]
  def self.export_to_csv
    CSV.generate(headers: true, force_quotes: true) do |csv|
      csv << ['name', 'website']
      all.each do |brand|
        csv << [brand.name, brand.website]
      end
    end
  end

  # @param [File] file
  def self.import(file)
    csv_raw = File.read(file.path)
    csv = CSV.parse(csv_raw, headers: true)
    csv.each do |row|
      brand = Brand.find_or_initialize_by(name: row['name'])
      brand.website = row['website']
      brand.save!
    end

  end
end
