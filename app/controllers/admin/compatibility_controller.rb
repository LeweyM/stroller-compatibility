class Admin::CompatibilityController < Admin::BaseController
  def index
    @adapters_with_products_by_type = Adapter.all.each_with_object(Hash.new { |h, k| h[k] = [] }) do |adapter, hash|
      hash[adapter.product] = CompatibleProduct.for_adapter(adapter)
                                               .group_by { |cpp| cpp.product.productable_type }
      hash[adapter.product]['Seat'] ||= []
      hash[adapter.product]['Stroller'] ||= []
    end
  end

  def link
    adapter = Product.friendly.find(params[:adapter])
    product_a = Product.friendly.find(params[:product_a])

    product_a.link!(adapter)
  end

  def unlink
    adapter = Product.friendly.find(params[:adapter])
    product_a = Product.friendly.find(params[:product_a])

    product_a.unlink!(adapter)
  end

  private

  # todo: make this into a model, i.e. product_set model which has products and where they come from (like a link or tag)
  def add_from_link_tags(product, product_ids_from_links)
    product.instance_variable_set(:@from_link, product_ids_from_links.include?(product.id))
    product.define_singleton_method(:from_link) { @from_link }
    product
  end
end