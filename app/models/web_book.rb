class WebBook < ApplicationRecord
  CONSUMPTION_TAX_RATE = 1.1

  has_many :web_book_authors, dependent: :destroy
  has_many :authors, through: :web_book_authors
  has_many :purchase_records, dependent: :restrict_with_exception
  has_many :users, through: :purchase_records
  has_many :pages, dependent: :destroy
  has_one_attached :cover_image
  scope :recently_released, -> { order(release_date: :desc) }
  scope :recently_saved, -> { order(id: :desc) }
  scope :released, -> { where(released: true) }
  validates :title, presence: true
  validates :release_date, presence: true
  validates :price, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :description, presence: true
  validates :cover_image, attached: true, content_type: ['image/png', 'image/jpg', 'image/jpeg']
  before_save :not_release_without_pages
  before_destroy :not_delete_released_web_book

  def principal_author_names
    authors.sort_by { |author| self.web_book_authors.sort_by(&:id).pluck(:author_id).index(author.id) }.pluck(:name).join('、')
  end

  def price_including_tax
    (self.price * CONSUMPTION_TAX_RATE).floor
  end

  def deletable?
    !self.released? && self.purchase_records.empty?
  end

  private

  def not_release_without_pages
    if self.released? && self.pages.size.zero?
      errors.add(:base, 'ページのないWebブックは公開できません')
      throw :abort
    end
  end

  def not_delete_released_web_book
    if self.released?
      errors.add(:base, '公開済みのWebブックは削除できません')
      throw :abort
    end
  end
end
