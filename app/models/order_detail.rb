class OrderDetail < ApplicationRecord
  belongs_to :user, optional: true
  has_many :purchase_records, dependent: :destroy
  scope :recently_ordered, -> { order(id: :desc) }
  validates :total_amount, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def self.order_web_books(web_books, user)
    ActiveRecord::Base.transaction do
      # Webブックが0冊で注文されるのを防ぐため記述
      raise Exceptions::OrdersControllerError, 'カートが空の状態で注文処理が実行されました' if web_books.empty?

      order_detail = user.order_details.create!(total_amount: web_books.sum(&:price_including_tax), paid: false)
      web_books.each do |web_book|
        order_detail.purchase_records.create!(web_book: web_book, user: user)
      end
    end
    true
  rescue
    false
  end
end
