class WebBookAuthor < ApplicationRecord
  belongs_to :web_book
  belongs_to :author
  validates :author, uniqueness: { scope: :web_book }
end
