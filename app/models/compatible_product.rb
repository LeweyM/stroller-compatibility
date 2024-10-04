class CompatibleProduct
  attr_reader :product, :from_link, :adapter

  def self.for_product(product)
    res = product.combined_adapters.map do |adapter|
      (adapter.compatible_products_via_direct + adapter.compatible_products_via_tag)
        .filter { |p| p.product.productable_type != product.productable_type }
    end.flatten
                 .uniq { |cp| cp.product.id }
                 .filter { |cp| cp.product.id != product.id }

    res.sort_by { |cp| cp.product.slug }
  end

  def initialize(product, from_link, adapter)
    @product = product
    @from_link = from_link
    @adapter = adapter
  end

  def ==(other)
    product == other.product && from_link == other.from_link && adapter == other.adapter
  end
end