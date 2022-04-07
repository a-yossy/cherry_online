class Author < ApplicationRecord
  has_many :web_book_authors, dependent: :destroy
  has_many :web_books, through: :web_book_authors
  validates :name, presence: true, uniqueness: true
end
