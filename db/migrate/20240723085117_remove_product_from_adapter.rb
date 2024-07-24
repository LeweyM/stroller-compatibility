class RemoveProductFromAdapter < ActiveRecord::Migration[7.1]
  def change
  #   remove product from adapter
    remove_reference :adapters, :product, null: false, foreign_key: true
  end
end
