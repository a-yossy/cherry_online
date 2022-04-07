class AddIndexToPagesTitle < ActiveRecord::Migration[6.1]
  def change
    add_index :pages, [:web_book_id, :title], unique: true
  end
end
