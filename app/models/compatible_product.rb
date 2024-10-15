class CompatibleProduct
  attr_reader :product, :tags, :adapter

  def self.for_product(product)
    res = product.combined_adapters
                 .flat_map { |adapter| for_adapter(adapter, product.productable_type) }
                 .uniq { |cp| cp.product.id }
                 .filter { |cp| cp.product.id != product.id }

    res.sort_by { |cp| cp.product.slug }
  end

  def from_tags?
    @tags.is_a?(Array) && !@tags.empty?
  end

  def self.for_adapter(adapter, not_type = 'Adapter')
    direct_compatible_product = adapter.compatible_products_via_direct
                                       .where.not(productable_type: not_type)
                                       .map { |pp| new(product: pp, adapter: adapter.product) }
    tag_compatible_products = adapter.compatible_products_via_tag
                                     .where.not(productable_type: not_type)
                                     .map { |pp| new(product: pp,
                                                     tags_from_link: get_tags_joining_product_and_adapter(pp, adapter),
                                                     adapter: adapter.product
                                     ) }

    direct_compatible_product + tag_compatible_products
  end

  def initialize(product:, tags_from_link: [], adapter:)
    @product = product
    @tags = tags_from_link
    @adapter = adapter
  end

  def ==(other)
    product == other.product && tags == other.tags && adapter == other.adapter
  end

  private

  def self.get_tags_joining_product_and_adapter(product, adapter)
    adapter.product.tags & product.tags
  end
end