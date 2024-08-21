class CreateProductAdapters < ActiveRecord::Migration[7.1]
  def change
    create_table :product_adapters do |t|
      t.references :product, null: false, foreign_key: true
      t.references :adapter, null: false, foreign_key: true

      t.timestamps
    end

    # Optionally, add an index to prevent duplicate entries
    add_index :product_adapters, [:product_id, :adapter_id], unique: true
  end
end