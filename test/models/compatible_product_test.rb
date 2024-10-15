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
    assert_equal [[]], result.map(&:tags)
    assert_equal [false], result.map(&:from_tags?)
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
                   CompatibleProduct.new(product: @seat_b, adapter: @adapter_1),
                   CompatibleProduct.new(product: seat_d, tags_from_link: [tag], adapter: @adapter_1)
                 ], result
  end
  test 'for_product returns all tags used to link the products' do
    # link product_d to adapter_1 via a tag
    linked_seat = create_product! type: Seat, name: 'linked_seat'
    linked_stroller = create_product! type: Stroller, name: 'linked_stroller'
    adapter = create_product! type: Adapter
    tag_1 = Tag.create!(label: "tag_1", brand: brands(:maxicosi))
    tag_2 = Tag.create!(label: "tag_2", brand: brands(:maxicosi))

    linked_seat.add_tag(tag_1)
    linked_seat.add_tag(tag_2)
    linked_stroller.add_tag(tag_1)
    linked_stroller.add_tag(tag_2)
    adapter.add_tag(tag_1)
    adapter.add_tag(tag_2)

    result = CompatibleProduct.for_product(linked_seat)
    assert_equal 1, result.size
    assert_equal result.first.tags, [tag_1, tag_2]
  end
end