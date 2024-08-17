require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  url = 'https://www.maxicosi.com/maxicosi_120'

  setup do
    @brand = Brand.create!(name: 'some-brand')
    @product_a = create_product! type: Stroller, brand: @brand, url: url
    @product_b = create_product! type: Stroller, brand: @brand
    @product_a.link!(@product_b)
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

class ProductCompatibleTest < ActiveSupport::TestCase
  setup do
    @product_a = create_product! type: Stroller
    @product_b = create_product! type: Stroller
    @product_c = create_product! type: Stroller
    @adapter = create_product! type: Adapter
    @product_a.link!(@product_b)
    @product_a.link!(@product_c, @adapter)
  end

  test 'is_compatible_with? returns true for compatible products without adapter' do
    assert @product_a.is_compatible_with?(@product_b, nil)
  end

  test 'is_compatible_with? returns false for incompatible products' do
    assert_not @product_b.is_compatible_with?(@product_c, nil)
  end

  test 'is_compatible_with? handles nil other_product' do
    assert_not @product_a.is_compatible_with?(nil, nil)
  end

  test 'is_compatible_with? handles compatibility in both directions' do
    assert @product_b.is_compatible_with?(@product_a, nil)
  end

  test 'is_compatible_with? handles compatibility with adapter' do
    assert @product_c.is_compatible_with?(@product_a, @adapter)
  end

  test 'is_compatible_with? handles compatibility with adapter in both directions' do
    assert @product_a.is_compatible_with?(@product_c, @adapter)
  end

  test 'is_compatible_with? returns false if adapter is not provided' do
    assert_not @product_a.is_compatible_with?(@product_c, nil)
  end

  test 'is_compatible_with? returns false if wrong adapter is provided' do
    assert_not @product_a.is_compatible_with?(@product_c, create_product!(type: Adapter))
  end
end

class ProductLinkTest < ActiveSupport::TestCase
  setup do
    @product_a = create_product! type: Stroller
    @product_b = create_product! type: Stroller
    @product_c = create_product! type: Stroller
    @adapter = create_product! type: Adapter
  end

  test 'link creates a new CompatibleLink but does not save' do
    link = @product_a.link(@product_b)
    assert_not link.persisted?

    link_saved = create_product!.link!(create_product!)
    assert link_saved.persisted?
  end

  test 'link creates a CompatibleLink between two products' do
    @product_a.link!(@product_b)
    assert CompatibleLink.exists?(product_a: @product_a, product_b: @product_b)
  end

  test 'link creates a CompatibleLink with adapter' do
    @product_a.link!(@product_b, @adapter)
    assert CompatibleLink.exists?(product_a: @product_a, product_b: @product_b, adapter: @adapter)
  end

  test 'link sorts products before creating CompatibleLink' do
    @product_b.link!(@product_a)
    assert CompatibleLink.exists?(product_a: @product_a, product_b: @product_b)
  end

  test 'link raises an error when trying to link a product to itself' do
    assert_raises(RuntimeError, "Cannot link a product to itself") do
      @product_a.link(@product_a)
    end
  end

  test 'link raises a validation error if a symmetrical link already exists' do
    p1 = create_product!
    p2 = create_product!
    p1.link!(p2)
    assert_raises(ActiveRecord::RecordInvalid) do
      p2.link!(p1)
    end
    assert_equal 1, p1.compatible_products.count
  end

  test 'link! creates a new CompatibleLink for different product pairs' do
    @product_a.link!(@product_b)
    @product_a.link!(@product_c)
    assert_equal 2, CompatibleLink.where(product_a: @product_a).count
  end

  test 'creates a new link! if a link! already exists with a different adapter' do
    @product_a.link!(@product_b)
    @product_a.link!(@product_b, @adapter)
    @product_a.link!(@product_b, create_product!(type: Adapter))
    assert_equal 3, CompatibleLink.where(product_a: @product_a).count
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
    @product_a.link!(@product_b, @adapter_1)
    @product_a.link!(@product_c, @adapter_2)
    @product_a.link!(@product_d)
  end

  test 'compatible_products_by_adapter returns correct grouping' do
    result = @product_a.compatible_products_by_adapter
    assert_equal 3, result.keys.size
    assert_includes result.keys, @adapter_1
    assert_includes result.keys, @adapter_2
    assert_includes result.keys, nil
  end

  test 'compatible_products_by_adapter groups products correctly' do
    result = @product_a.compatible_products_by_adapter
    assert_equal [@product_b], result[@adapter_1]
    assert_equal [@product_c], result[@adapter_2]
    assert_equal [@product_d], result[nil]
  end

  test 'compatible_products_by_adapter handles bidirectional compatibility' do
    @product_b.link!(@product_c, @adapter_1)
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
    @product_a.link!(@product_d, @adapter_1)
    result = @product_a.compatible_products_by_adapter
    assert_equal [@product_b, @product_d], result[@adapter_1]
  end
end
