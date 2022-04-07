class Page < ApplicationRecord
  include RankedModel
  belongs_to :web_book
  ranks :page_order, with_same: :web_book_id
  validates :title, presence: true, uniqueness: { scope: :web_book_id }
  validates :body, presence: true
  before_destroy :not_delete_only_one_page_left

  def deletable?
    !self.web_book.released? || self.web_book.pages.size > 1
  end

  private

  def not_delete_only_one_page_left
    unless self.deletable?
      errors.add(:base, '公開済みのWebブックは0ページにできません')
      throw :abort
    end
  end
end
