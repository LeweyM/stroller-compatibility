class MakeImageUrlRequired < ActiveRecord::Migration[7.1]
  def change
    change_column_null :images, :url, false
  end
end
