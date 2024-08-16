class RemoveLinkFromSeats < ActiveRecord::Migration[7.1]
  def change
    remove_column :seats, :link, :string
  end
end
