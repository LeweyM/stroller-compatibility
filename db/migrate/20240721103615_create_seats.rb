class CreateSeats < ActiveRecord::Migration[7.1]
  def change
    create_table :seats do |t|
      t.references :brand, null: false, foreign_key: true
      t.string :name
      t.string :link

      t.timestamps
    end
  end
end
