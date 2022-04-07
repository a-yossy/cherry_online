class CreatePages < ActiveRecord::Migration[6.1]
  def change
    create_table :pages do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.references :web_book, null: false, foreign_key: true

      t.timestamps
    end
  end
end
