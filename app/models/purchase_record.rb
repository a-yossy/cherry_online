class PurchaseRecord < ApplicationRecord
  belongs_to :web_book
  belongs_to :user, optional: true
  belongs_to :order_detail
  validates :web_book, uniqueness: { scope: :user }
  scope :recently_ordered, -> { order(id: :desc) }
  scope :formerly_ordered, -> { order(id: :asc) }
end
