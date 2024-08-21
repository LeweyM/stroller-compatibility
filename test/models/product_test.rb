require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  url = 'https://www.maxicosi.com/maxicosi_120'

  setup do
    @brand = Brand.create!(name: 'some-brand')
    @product_a = create_product! type: Stroller, brand: @brand, url: url
    @product_b = create_product! type: Stroller, brand: @brand
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
end

class ProductCompatibleTest < ActiveSupport::TestCase
  setup do
    @product_a = create_product! type: Stroller
    @product_b = create_product! type: Stroller
    @product_c = create_product! type: Stroller
    @adapter = create_product! type: Adapter
    @product_a.link!(@adapter)
    @product_c.link!(@adapter)
  end

  test 'is_compatible_with? returns false for incompatible products' do
    assert_not @product_b.is_compatible_with?(@product_c)
  end

  test 'is_compatible_with? handles compatibility in both directions' do
    assert @product_a.is_compatible_with?(@product_c)
    assert @product_c.is_compatible_with?(@product_a)
  end

  test 'is_compatible_with? handles compatibility with adapter' do
    assert @product_c.is_compatible_with?(@product_a)
  end

  test 'is_compatible_with? handles compatibility with adapter in both directions' do
    assert @product_a.is_compatible_with?(@product_c)
  end
end

class ProductLinkTest < ActiveSupport::TestCase
  setup do
    @product_a = create_product! type: Stroller
    @product_b = create_product! type: Stroller
    @product_c = create_product! type: Stroller
    @adapter = create_product! type: Adapter
  end

  test 'link! creates a link between a product and an adapter' do
    @product_a.link!(@adapter)
    assert_equal @adapter, @product_a.adapters.first.product
  end

  test 'link! raises an error when trying to link a product directly to another product' do
    assert_raises(RuntimeError, "Cannot link a product to another product") do
      @product_a.link!(@product_b)
    end
  end

  test 'link! raises an error when trying to link a product to itself' do
    assert_raises(RuntimeError, "Cannot link a product to itself") do
      @product_a.link!(@product_a)
    end
  end

  test 'unlink! removes a link between a product and an adapter' do
    @product_a.link!(@adapter)
    @product_a.unlink!(@adapter)
    assert_equal 0, @product_a.adapters.size
  end

  test 'unlink! raises an error when trying to unlink a product directly to another product' do
    assert_raises(RuntimeError, "Cannot unlink a product to another product") do
      @product_a.unlink!(@product_b)
    end
  end

  test 'unlink! raises an error when trying to unlink a product to itself' do
    assert_raises(RuntimeError, "Cannot unlink a product to itself") do
      @product_a.unlink!(@product_a)
    end
  end
end

class ProductCompatibleProductsByAdapterTest < ActiveSupport::TestCase
  setup do
    @product_a = create_product! type: Stroller
    @product_b = create_product! type: Stroller
    @product_c = create_product! type: Stroller
    @product_d = create_product! type: Stroller
    @adapter_1 = create_product! type: Adapter
    @adapter_2 = create_product! type: Adapter
    @product_a.link!(@adapter_1)
    @product_b.link!(@adapter_1)
    @product_a.link!(@adapter_2)
    @product_c.link!(@adapter_2)
  end

  test 'compatible_products_by_adapter returns correct grouping' do
    result = @product_a.compatible_products_by_adapter
    assert_equal 2, result.keys.size
    assert_includes result.keys, @adapter_1
    assert_includes result.keys, @adapter_2
  end

  test 'compatible_products_by_adapter groups products correctly' do
    result = @product_a.compatible_products_by_adapter
    assert_equal [@product_b], result[@adapter_1]
    assert_equal [@product_c], result[@adapter_2]
  end

  test 'compatible_products_by_adapter handles bidirectional compatibility' do
    @product_c.link!(@adapter_1)
    result = @product_b.compatible_products_by_adapter
    adapter_count = result.keys.size
    assert_equal 1, adapter_count
    assert_equal [@product_a, @product_c], result[@adapter_1]
  end

  test 'compatible_products_by_adapter returns empty hash for product with no compatibility' do
    isolated_product = create_product! type: Stroller
    result = isolated_product.compatible_products_by_adapter
    assert_empty result
  end

  test 'compatible_products_by_adapter handles multiple products with same adapter' do
    @product_d.link!(@adapter_1)
    result = @product_a.compatible_products_by_adapter
    assert_equal [@product_b, @product_d], result[@adapter_1]
  end
end
