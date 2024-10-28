require "test_helper"
require_relative './base_import_test'

class TagTest < ActiveSupport::TestCase
  test "should get all products for a tag" do
    infant_tag = tags(:infant)
    assert_equal 3, infant_tag.products.length
    assert_equal [products(:oxford), products(:cabriofix), products(:'maxicosi infant adapter')].sort, infant_tag.products.sort
  end

  class TagImportTest < Admin::BaseImportTest

    test "should import tags correctly" do
      csv = %w["maxicosi","maxicosi" "tag1","tag2" "oxford","cabriofix" "cabriofix",""].join("\n")
      file = prepare_test_file(csv, "tags_test")

      Tag.import(file)

      tag_1 = Tag.find_by(label: "tag1")
      tag_2 = Tag.find_by(label: "tag2")
      assert_equal %w[oxford cabriofix].sort, tag_1.products.map(&:slug).sort
      assert_equal %w[cabriofix], tag_2.products.map(&:slug)
    end

    test "should not make any changes if one brand does not exist" do
      csv = %w[maxicosi,some-brand-that-doesnt-exist tag1,tag2 oxford,cabriofix cabriofix].join("\n")
      file = prepare_test_file(csv, "tags_test")

      assert_raises { Tag.import(file) }
      assert_nil Tag.find_by(label: "tag1")
      assert_nil Tag.find_by(label: "tag2")
    end

    test "should not make any changes if one product does not exist" do
      csv = %w[maxicosi,maxicosi tag1,tag2 oxford,cabriofix cabriofix,some-product-that-doesnt-exist].join("\n")
      file = prepare_test_file(csv, "tags_test")

      assert_raises { Tag.import(file) }
      assert_nil Tag.find_by(label: "tag1")
      assert_nil Tag.find_by(label: "tag2")
    end

  end

end
