require 'rails_helper'

RSpec.describe Author, type: :model do
  describe 'validations' do
    before { create(:author) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:web_book_authors).dependent(:destroy) }
    it { is_expected.to have_many(:web_books).through(:web_book_authors) }
  end
end
