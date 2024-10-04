require 'test_helper'

class ProductTest < ActiveSupport::TestCase
  url = 'https://www.maxicosi.com/maxicosi_120'

  setup do
    @brand = Brand.create!(name: 'some-brand')
    @stroller_a = create_product! type: Stroller, brand: @brand, url: url
    @seat_b = create_product! type: Stroller, brand: @brand
  end

  test 'should be valid' do
    assert @stroller_a.valid?
  end

  test 'should require a name' do
    @stroller_a.name = nil
    assert_not @stroller_a.valid?
  end

  test 'should belong to a brand' do
    assert_equal @brand, @stroller_a.brand
  end

  test 'should return the correct product URL' do
    assert_equal url, @stroller_a.url
  end
end

class ProductCompatibleTest < ActiveSupport::TestCase
  setup do
    @stroller_a = create_product! type: Stroller
    @seat_b = create_product! type: Stroller
    @stroller_c = create_product! type: Stroller
    @adapter = create_product! type: Adapter
    @stroller_a.link!(@adapter)
    @stroller_c.link!(@adapter)
  end
end

class ProductLinkTest < ActiveSupport::TestCase
  setup do
    @stroller_a = create_product! type: Stroller
    @seat_b = create_product! type: Stroller
    @stroller_c = create_product! type: Stroller
    @adapter = create_product! type: Adapter
  end

  test 'link! creates a link between a product and an adapter' do
    @stroller_a.link!(@adapter)
    assert_equal @adapter, @stroller_a.adapters.first.product
  end

  test 'link! raises an error when trying to link a product directly to another product' do
    assert_raises(RuntimeError, "Cannot link a product to another product") do
      @stroller_a.link!(@seat_b)
    end
  end

  test 'link! raises an error when trying to link a product to itself' do
    assert_raises(RuntimeError, "Cannot link a product to itself") do
      @stroller_a.link!(@stroller_a)
    end
  end

  test 'unlink! removes a link between a product and an adapter' do
    @stroller_a.link!(@adapter)
    @stroller_a.unlink!(@adapter)
    assert_equal 0, @stroller_a.adapters.size
  end

  test 'unlink! raises an error when trying to unlink a product directly to another product' do
    assert_raises(RuntimeError, "Cannot unlink a product to another product") do
      @stroller_a.unlink!(@seat_b)
    end
  end

  test 'unlink! raises an error when trying to unlink a product to itself' do
    assert_raises(RuntimeError, "Cannot unlink a product to itself") do
      @stroller_a.unlink!(@stroller_a)
    end
  end
end

class ProductCompatibleProductsByAdapterTest < ActiveSupport::TestCase
  setup do
    # stroller_a -> adapter_1 -> seat_b
    # stroller_a -> adapter_2 -> stroller_c
    @stroller_a = create_product! type: Stroller
    @stroller_c = create_product! type: Stroller
    @seat_b = create_product! type: Seat
    @seat_d = create_product! type: Seat
    @adapter_1 = create_product! type: Adapter
    @adapter_2 = create_product! type: Adapter
    @stroller_a.link!(@adapter_1)
    @seat_b.link!(@adapter_1)
    @stroller_a.link!(@adapter_2)
    @stroller_c.link!(@adapter_2)
  end

  test 'compatible_products_by_adapter returns correct grouping' do
    result = @stroller_a.compatible_products_by_adapter
    assert_equal result.keys, [@adapter_1.slug]
  end

  test 'compatible_products_by_adapter groups products correctly' do
    result = @stroller_a.compatible_products_by_adapter
    assert_equal result.keys, [@adapter_1.slug]
    assert_equal [@seat_b], result[@adapter_1.slug].map(&:product)
  end

  test 'compatible_products_by_adapter handles bidirectional compatibility' do
    @stroller_c.link!(@adapter_1)

    result = @seat_b.compatible_products_by_adapter
    adapter_count = result.keys.size
    assert_equal 1, adapter_count
    assert_equal [@stroller_a, @stroller_c].sort, result[@adapter_1.slug].map(&:product).sort
  end

  test 'compatible_products_by_adapter returns empty hash for product with no compatibility' do
    isolated_product = create_product! type: Stroller
    result = isolated_product.compatible_products_by_adapter
    assert_empty result
  end

  test 'compatible_products_by_adapter handles multiple products with same adapter' do
    @seat_d.link!(@adapter_1)
    result = @seat_d.compatible_products_by_adapter
    assert_equal [@stroller_a].sort, result[@adapter_1.slug].map(&:product).sort
  end

  test 'only gets products of a different type' do
    stroller = create_product! type: Stroller
    another_stroller = create_product! type: Stroller
    seat = create_product! type: Seat
    adapter = create_product! type: Adapter
    stroller.link!(adapter)
    another_stroller.link!(adapter)
    seat.link!(adapter)

    result = stroller.compatible_products_by_adapter

    assert_not_includes result[adapter.slug].map(&:product), another_stroller
    assert_includes result[adapter.slug].map(&:product), seat
  end
end
