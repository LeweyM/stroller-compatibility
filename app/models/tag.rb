class Tag < ApplicationRecord
  belongs_to :brand
  has_and_belongs_to_many :products

  validates :label, presence: true

  # @param [File] file  # @return [Integer] - Number of new tag records created
  def self.import(file)
    csv_text = File.read(file)
    csv = CSV.parse(csv_text, headers: false)
    cols = csv.reduce(&:zip).map(&:flatten)
    count = 0
    ActiveRecord::Base.transaction do
      cols.each do |col|
        brand_name = col[0]
        tag_label = col[1]
        products = col[2..].reject(&:blank?)
        brand = Brand.find_by(name: brand_name)
        if brand.nil?
          raise "Error: brand #{brand_name} not found"
        end

        tag = Tag.find_by(label: col)
        if tag.nil?
          tag = Tag.create!(label: tag_label, brand: brand)
          count += 1
        end
        products.filter { |p| !p.nil? }.each do |product_name|
          product = Product.friendly.find_by(slug: product_name)
          if product.nil?
            raise "Error: product #{product_name} not found"
          end
          product.add_tag tag
        end
      end
    end
    count
  end

end
