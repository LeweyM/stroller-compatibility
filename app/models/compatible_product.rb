class CompatibleProduct
  attr_reader :product, :from_link

  def initialize(product, from_link)
    @product = product
    @from_link = from_link
  end
end
