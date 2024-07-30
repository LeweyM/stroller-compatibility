class CreateImages < ActiveRecord::Migration[7.1]
  def change
    create_table :images do |t|
      t.string :url
      t.string :alt_text
      t.string :attribution_url
      t.string :attribution_text
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
