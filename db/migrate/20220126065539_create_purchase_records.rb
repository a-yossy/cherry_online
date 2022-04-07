class CreatePurchaseRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :purchase_records do |t|
      t.references :web_book, foreign_key: true
      t.references :user, foreign_key: true
      t.references :order_detail, null: false, foreign_key: true

      t.timestamps
    end
    add_index :purchase_records, [:web_book_id, :user_id], unique: true
  end
end
