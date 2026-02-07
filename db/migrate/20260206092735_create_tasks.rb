class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :assignee, foreign_key: { to_table: :users }, null: true
      t.references :list, null: false, foreign_key: true

      t.string :title, null: false
      t.text :description
      t.integer :priority
      t.datetime :deadline
      t.integer :status, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.integer :comments_count, null: false, default: 0

      t.timestamps
    end
  end
end
