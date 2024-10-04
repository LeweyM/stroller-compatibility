require 'test_helper'

class CompatibleProductTest < ActiveSupport::TestCase
  setup do
    # stroller_a -> adapter_1 -> seat_b
    # stroller_a -> adapter_2 -> stroller_c
    @stroller_a = create_product! type: Stroller, name: 'product_a'
    @seat_b = create_product! type: Seat, name: 'product_b'
    @stroller_c = create_product! type: Stroller, name: 'product_c'
    @adapter_1 = create_product! type: Adapter, name: 'adapter_1'
    @adapter_2 = create_product! type: Adapter, name: 'adapter_2'
    @stroller_a.link!(@adapter_1)
    @seat_b.link!(@adapter_1)
    @stroller_a.link!(@adapter_2)
    @stroller_c.link!(@adapter_2)
  end

  test 'for_product returns correct products for products directly linked to adapters' do
    result = CompatibleProduct.for_product(@stroller_a)
    assert_equal 1, result.size
    assert_equal [@seat_b], result.map(&:product)
    assert_equal [@adapter_1], result.map(&:adapter)
    assert_equal [false], result.map(&:from_link)
  end

  test 'for_product returns correct products for products linked to adapters via tags' do
    # link product_d to adapter_1 via a tag
    seat_d = create_product! type: Seat, name: 'seat_d'
    tag = Tag.create!(label: "some_tag", brand: brands(:maxicosi))
    seat_d.add_tag(tag)
    @stroller_a.add_tag(tag) # todo: should not be necessary. Either link or tag-link should be enough for both products.
    @adapter_1.add_tag(tag)

    result = CompatibleProduct.for_product(@stroller_a)
      assert_equal [
        CompatibleProduct.new(@seat_b, false, @adapter_1),
        CompatibleProduct.new(seat_d, true, @adapter_1)
      ], result
    end
end