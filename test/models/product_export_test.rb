require 'test_helper'

class ProductExportTest < ActiveSupport::TestCase
  setup do
    @brand = Brand.create!(name: 'TestBrand')
    @stroller = create_product! type:Stroller, name:'Stroller1', brand:@brand, url:'http://example.com/stroller1', fix_name: true
    @seat = create_product! type: Seat, brand: @brand, name: 'Seat1', url: 'http://example.com/seat1', fix_name:true
    @adapter = Product.create!(productable: Adapter.create!, brand: @brand, name: 'Adapter1')

    @stroller.link! @adapter
    @seat.link! @adapter
  end

  test "export_all generates a CSV string with all products" do
    lines = Product.export_all.split("\n")

    assert_equal 'type,brand,name,url,image_url', lines[0]
    assert_includes lines, 'Adapter,TestBrand,Adapter1,,'
    assert_includes lines, 'Seat,TestBrand,Seat1,http://example.com/seat1,'
    assert_includes lines, 'Stroller,TestBrand,Stroller1,http://example.com/stroller1,'
  end

  test "export_compatible generates a CSV string with compatibility information" do
    lines = Product.export_compatible.split("\n")

    # lines 0-5 are data from fixtures
    assert_equal 'Stroller1', lines[6]
    assert_equal 'Seat1', lines[7]
    assert_equal 'Adapter1', lines[8]
  end

  test "export_tags generates a CSV string with tag data" do
    lines = Product.export_tags.split("\n")

    assert_equal 'maxicosi', lines[0]
    assert_equal 'infant', lines[1]
    assert_equal 'cabriofix', lines[2]
    assert_equal 'oxford', lines[3]
    assert_equal 'infant adapter', lines[4]
  end

  test "export_tags generates a CSV string with tag data when more than 1 tags exist" do
    tag = Tag.create!(label: 'newborn', brand: brands(:maxicosi))
    oxford = products(:oxford)
    oxford.add_tag tag

    lines = Product.export_tags.split("\n")

    assert_equal 'maxicosi,maxicosi', lines[0]
    assert_equal 'infant,newborn', lines[1]
    assert_equal 'cabriofix,oxford', lines[2]
    assert_equal 'oxford,', lines[3]
    assert_equal 'infant adapter,', lines[4]
  end
end
