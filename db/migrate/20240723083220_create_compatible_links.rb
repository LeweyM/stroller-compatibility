class CreateCompatibleLinks < ActiveRecord::Migration[7.1]
  def change
    create_table :compatible_links do |t|
      t.references :product_a, null: false, foreign_key: {to_table: :products, on_delete: :cascade}
      t.references :product_b, null: false, foreign_key: {to_table: :products, on_delete: :cascade}
      t.references :adapter, null: true, foreign_key: {to_table: :products, on_delete: :cascade}

      t.timestamps
    end
  end
end
