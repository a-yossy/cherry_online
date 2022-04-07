class CreateOrderDetails < ActiveRecord::Migration[6.1]
  def change
    create_table :order_details do |t|
      t.integer :total_amount, null: false
      t.boolean :paid, null: false, default: false
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
