class ChangeStringColumnDefault < ActiveRecord::Migration[6.1]
  def change
    change_column_default :web_books, :title, from: nil, to: ''
    change_column_default :web_books, :description, from: nil, to: ''
    change_column_default :authors, :name, from: nil, to: ''
    change_column_default :pages, :title, from: nil, to: ''
    change_column_default :pages, :body, from: nil, to: ''
    change_column_default :users, :name, from: nil, to: ''
  end
end
