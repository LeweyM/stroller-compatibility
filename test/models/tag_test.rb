require "test_helper"

class TagTest < ActiveSupport::TestCase
  test "should get all products for a tag" do
    infant_tag = tags(:infant)
    assert_equal 3, infant_tag.products.length
    assert_equal [products(:oxford), products(:cabriofix), products(:'maxicosi infant adapter')].sort, infant_tag.products.sort
  end

  class TagImportTest < TagTest

    def generate_csv_row(defaults = {})
      # Generate a unique name using a timestamp or a sequence number
      unique_suffix = Time.now.to_i.to_s + rand(1000).to_s

      # Define default values for each column, ensuring 'name' is always unique
      defaults = {
        type: "seat",
        brand: "maxicosi",
        name: "defaultName_#{unique_suffix}",
        link: "http://example.com/default",
        image_url: "http://example.com/default.jpg"
      }.merge(defaults)

      # Override the name specifically if provided
      defaults[:name] = "#{defaults[:name]}_#{unique_suffix}" unless defaults.key?(:name)

      # Create a CSV row string
      CSV.generate_line([defaults[:type], defaults[:brand], defaults[:name], defaults[:link], defaults[:image_url]], force_quotes: true)
    end

    def prepare_test_file(content, filename)
      temp_file = Tempfile.new([filename, '.csv'])
      temp_file.write(content)
      temp_file.rewind
      Rack::Test::UploadedFile.new(temp_file, "text/csv", original_filename: filename + ".csv")
    end

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
