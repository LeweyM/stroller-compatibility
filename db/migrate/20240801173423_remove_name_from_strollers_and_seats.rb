class RemoveNameFromStrollersAndSeats < ActiveRecord::Migration[7.1]
  def change
    remove_column :strollers, :name
    remove_column :seats, :name
  end
end
