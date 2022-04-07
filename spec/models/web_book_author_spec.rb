require 'rails_helper'

RSpec.describe WebBookAuthor, type: :model do
  describe 'validations' do
    describe 'uniqueness with web_book and author' do
      subject do
        web_book_author.valid?
        web_book_author.errors
      end

      let(:web_book) { create(:web_book) }
      let(:web_book_author) { build(:web_book_author, web_book: web_book, author: author) }
      let(:existed_author) { create(:author, name: 'existed_author') }

      before { create(:web_book_author, web_book: web_book, author: existed_author) }

      context 'with the same name' do
        let(:author) { Author.find_by(name: 'existed_author') }

        it { is_expected.to be_of_kind(:author, :taken) }
      end

      context 'with not the same name' do
        let(:author) { create(:author, name: 'author') }

        it { is_expected.not_to be_of_kind(:author, :taken) }
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:web_book).dependent(false) }
    it { is_expected.to belong_to(:author).dependent(false) }
  end
end
