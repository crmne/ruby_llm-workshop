class CreateTodos < ActiveRecord::Migration[8.1]
  def change
    create_table :todos do |t|
      t.string :title
      t.text :description
      t.string :status
      t.string :priority
      t.string :category
      t.date :due_date

      t.timestamps
    end
  end
end
