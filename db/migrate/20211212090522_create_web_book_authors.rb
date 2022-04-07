class CreateWebBookAuthors < ActiveRecord::Migration[6.1]
  def change
    create_table :web_book_authors do |t|
      t.references :web_book, null: false, foreign_key: true
      t.references :author, null: false, foreign_key: true

      t.timestamps
    end
    add_index :web_book_authors, [:web_book_id, :author_id], unique: true
  end
end
