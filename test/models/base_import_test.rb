require "test_helper"

module Admin
  class BaseImportTest < ActiveSupport::TestCase

    def prepare_test_file(content, filename)
      temp_file = Tempfile.new([filename, '.csv'])
      temp_file.write(content)
      temp_file.rewind
      Rack::Test::UploadedFile.new(temp_file, "text/csv", original_filename: filename + ".csv")
    end

  end
end
