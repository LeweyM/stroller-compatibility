class CreateAdapters < ActiveRecord::Migration[7.1]
  def change
    create_table :adapters do |t|
      t.references :product, null: false, foreign_key: true

      t.timestamps
    end
  end
end
