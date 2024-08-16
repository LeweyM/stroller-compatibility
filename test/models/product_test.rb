require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  url = 'https://www.maxicosi.com/maxicosi_120'

  setup do
    @brand = Brand.create!(name: 'some-brand')
    @product_a = create_product! type: Stroller, brand: @brand, url: url
    @product_b = create_product! type: Stroller, brand: @brand
    CompatibleLink.create!(product_a: @product_a, product_b: @product_b)
  end

  test 'should be valid' do
    assert @product_a.valid?
  end

  test 'should require a name' do
    @product_a.name = nil
    assert_not @product_a.valid?
  end

  test 'should belong to a brand' do
    assert_equal @brand, @product_a.brand
  end

  test 'should return the correct product URL' do
    assert_equal url, @product_a.url
  end

  test 'should return the compatible products' do
    assert_equal [@product_b], @product_a.compatible_products
  end
end
