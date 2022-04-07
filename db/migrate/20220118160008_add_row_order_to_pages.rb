class AddRowOrderToPages < ActiveRecord::Migration[6.1]
  def change
    add_column :pages, :page_order, :integer
  end
end
