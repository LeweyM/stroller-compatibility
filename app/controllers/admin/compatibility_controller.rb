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

    begin
      product_a.unlink!(adapter)
    rescue => e
      render json: { error: e.message }, status: :unprocessable_entity
    end
  end
end