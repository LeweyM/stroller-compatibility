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
end
