class RemoveBrandFromSeats < ActiveRecord::Migration[7.1]
  def change
    remove_reference :seats, :brand, null: false, foreign_key: true
  end
end
