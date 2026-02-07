class CreateBoards < ActiveRecord::Migration[8.0]
  def change
    create_table :boards do |t|
      t.references :user, null: false, foreign_key: true

      t.string :name, null: false
      t.text :description
      t.integer :position, null: false, default: 0
      t.datetime :archived_at, null: true
      t.boolean :visibility, null: false, default: true
      t.string :color, null: false, default: "#CCCCCC", limit: 9
      t.integer :lists_count, null: false, default: 0

      t.timestamps
    end
  end
end
