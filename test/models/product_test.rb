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

  test 'link creates only one CompatibleLink for the same product pair' do
    p1 = create_product!
    p2 = create_product!
    p1.link!(p2)
    p2.link!(p1)
    assert_equal 1, p1.compatible_products.count
    assert_equal 1, p2.compatible_products.count
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