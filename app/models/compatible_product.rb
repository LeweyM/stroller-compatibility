class CompatibleProduct
  attr_reader :product, :from_link, :adapter

  def self.for_product(product)
    res = product.combined_adapters
                 .flat_map { |adapter| for_adapter(adapter, product.productable_type) }
                 .uniq { |cp| cp.product.id }
                 .filter { |cp| cp.product.id != product.id }

    res.sort_by { |cp| cp.product.slug }
  end

  def self.for_adapter(adapter, not_type = 'Adapter')
    direct_compatible_product = adapter.compatible_products_via_direct
                                       .where.not(productable_type: not_type)
                                       .map { |pp| new(pp, false, adapter.product) }
    tag_compatible_products = adapter.compatible_products_via_tag
                                     .where.not(productable_type: not_type)
                                     .map { |pp| new(pp, true, adapter.product) }
    direct_compatible_product + tag_compatible_products
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