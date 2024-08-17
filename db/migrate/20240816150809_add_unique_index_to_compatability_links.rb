class AddUniqueIndexToCompatabilityLinks < ActiveRecord::Migration[7.1]
  def change
    add_index :compatible_links, [:product_a_id, :product_b_id, :adapter_id], unique: true, name: 'index_compatible_links'
  end
end
