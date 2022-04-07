class ChangeWebBookToPurchaseRecords < ActiveRecord::Migration[6.1]
  def change
    change_column_null :purchase_records, :web_book_id, false
  end
end
