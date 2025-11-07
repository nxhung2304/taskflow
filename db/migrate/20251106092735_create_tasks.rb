class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.integer :priority
      t.date :due_date
      t.integer :status

      t.timestamps
    end
  end
end
