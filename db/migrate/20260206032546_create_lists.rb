class CreateLists < ActiveRecord::Migration[8.0]
  def change
    create_table :lists do |t|
      t.references :board, null: false, foreign_key: true

      t.string :name, null: false
      t.integer :position, null: false, default: 0

      t.timestamps
    end
  end
end
