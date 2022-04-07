class User < ApplicationRecord
  has_many :purchase_records, dependent: :nullify
  has_many :web_books, through: :purchase_records
  has_many :order_details, dependent: :nullify
  validates :name, presence: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :rememberable, :validatable

  def recently_ordered_paid_web_books
    WebBook.joins(purchase_records: :order_detail).where(order_detail: { user_id: self.id, paid: true }).merge(PurchaseRecord.recently_ordered)
  end
end
