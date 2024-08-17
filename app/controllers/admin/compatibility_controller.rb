class Admin::CompatibilityController < Admin::BaseController
  def index
    compatible_links = CompatibleLink.includes(:product_a, :product_b, :adapter).all
    grouped_links = compatible_links.group_by { |link| link.adapter }

    @compatibility_links = grouped_links.transform_values do |links|
      merged = links.each_with_object(Hash.new { |h, k| h[k] = [] }) do |link, hash|
        hash[link.product_a.productable_type] << link.product_a
        hash[link.product_b.productable_type] << link.product_b
      end

      merged.transform_values!(&:uniq)
    end
  end

  def link
    adapter = Product.friendly.find(params[:adapter])
    product_a = Product.friendly.find(params[:product_a])
    product_b = Product.friendly.find(params[:product_b])

    product_a.link!(product_b, adapter)
  end

  def unlink
    adapter = Product.friendly.find(params[:adapter])
    product_a = Product.friendly.find(params[:product_a])
    product_b = Product.friendly.find(params[:product_b])

    product_a.unlink!(product_b, adapter)
  end

  private
end
