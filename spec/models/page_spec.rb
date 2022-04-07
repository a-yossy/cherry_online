require 'rails_helper'

RSpec.describe Page, type: :model do
  describe 'validations' do
    before { create(:web_book) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_uniqueness_of(:title).scoped_to(:web_book_id) }
    it { is_expected.to validate_presence_of(:body) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:web_book).dependent(false) }
  end

  describe 'ranks' do
    let!(:first_page) { create(:page) }
    let!(:second_page) { create(:page) }
    let!(:third_page) { create(:page) }

    before do
      # before_save回避のためにFactoryBotで作られたページを削除
      Page.where(title: 'delete_title').destroy_all
    end

    it 'sort in registration order' do
      expect(described_class.rank(:page_order)).to eq [first_page, second_page, third_page]
    end

    it 'sort in descending order of page_order' do
      expect { third_page.update(page_order: first_page.page_order - 1) }.
        to change { described_class.rank(:page_order) }.
        from([first_page, second_page, third_page]).
        to([third_page, first_page, second_page])
    end
  end

  describe '#deletable?' do
    let(:web_book) { create(:web_book, released: released) }
    let!(:page) { create(:page, web_book: web_book) }

    before do
      # before_save回避のためにFactoryBotで作られたページを削除
      Page.where(title: 'delete_title').destroy_all
    end

    context 'released web_book with two pages' do
      let(:released)  { true }

      before { create(:page, web_book: web_book) }

      it 'return true' do
        expect(page.deletable?).to eq true
      end
    end

    context 'not released web_book with two pages' do
      let(:released) { false }

      before { create(:page, web_book: web_book) }

      it 'return true' do
        expect(page.deletable?).to eq true
      end
    end

    context 'released web_book with one page' do
      let(:released) { true }

      it 'return false' do
        expect(page.deletable?).to eq false
      end
    end

    context 'not released web_book with one page' do
      let(:released) { false }

      it 'return true' do
        expect(page.deletable?).to eq true
      end
    end
  end

  describe '#not_delete_only_one_page_left' do
    let(:web_book) { create(:web_book, released: released) }
    let!(:web_book_page) { create(:page, web_book: web_book) }

    before do
      # before_save回避のためにFactoryBotで作られたページを削除
      Page.where(title: 'delete_title').destroy_all
    end

    context 'released web_book has two pages' do
      let(:released) { true }

      before { create(:page, web_book: web_book) }

      it 'delete page' do
        expect { web_book_page.destroy }.to change(Page, :count).by(-1)
      end
    end

    context 'not released web_book has two pages' do
      let(:released) { false }

      before { create(:page, web_book: web_book) }

      it 'delete page' do
        expect { web_book_page.destroy }.to change(Page, :count).by(-1)
      end
    end

    context 'released web_book has one page' do
      let(:released) { true }

      it 'do not delete page' do
        expect { web_book_page.destroy }.to change(Page, :count).by(0)
        expect(web_book_page.errors.full_messages).to eq ['公開済みのWebブックは0ページにできません']
      end
    end

    context 'not released web_book has one page' do
      let(:released) { false }

      it 'delete page' do
        expect { web_book_page.destroy }.to change(Page, :count).by(-1)
      end
    end
  end
end
