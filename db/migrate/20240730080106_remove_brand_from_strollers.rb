class RemoveBrandFromStrollers < ActiveRecord::Migration[7.1]
  def change
    remove_reference :strollers, :brand, null: false, foreign_key: true
  end
end
