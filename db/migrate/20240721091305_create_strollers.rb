class CreateStrollers < ActiveRecord::Migration[7.1]
  def change
    create_table :strollers do |t|
      t.references :brand, null: false, foreign_key: true
      t.string :name

      t.timestamps
    end
  end
end
