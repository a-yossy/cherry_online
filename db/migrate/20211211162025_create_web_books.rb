class CreateWebBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :web_books do |t|
      t.string :title, null: false
      t.date :release_date, null: false
      t.integer :price, null: false
      t.text :description, null: false
      t.boolean :released, null: false, default: false

      t.timestamps
    end
  end
end
