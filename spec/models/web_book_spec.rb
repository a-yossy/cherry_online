require 'rails_helper'

RSpec.describe WebBook, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:release_date) }
    it { is_expected.to validate_presence_of(:price) }
    it { is_expected.to validate_numericality_of(:price).only_integer }
    it { is_expected.to validate_numericality_of(:price).is_greater_than_or_equal_to(0) }
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_attached_of(:cover_image) }
    it { is_expected.to validate_content_type_of(:cover_image).allowing('image/png', 'image/jpg', 'image/jpeg') }
  end

  describe 'active_storage' do
    it { is_expected.to have_one_attached(:cover_image) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:web_book_authors).dependent(:destroy) }
    it { is_expected.to have_many(:authors).through(:web_book_authors) }
    it { is_expected.to have_many(:purchase_records).dependent(:restrict_with_exception) }
    it { is_expected.to have_many(:users).through(:purchase_records) }
    it { is_expected.to have_many(:pages).dependent(:destroy) }
  end

  describe 'recently_released' do
    let(:old_web_book) { create(:web_book, release_date: '2021-01-01') }
    let(:new_web_book) { create(:web_book, release_date: '2021-01-02') }

    it 'sort in descending order of release_date' do
      expect(described_class.recently_released).to eq [new_web_book, old_web_book]
    end
  end

  describe 'recently_saved' do
    let!(:old_web_book) { create(:web_book) }
    let(:new_web_book) { create(:web_book) }

    it 'sort in descending order of id' do
      expect(described_class.recently_saved).to eq [new_web_book, old_web_book]
    end
  end

  describe 'released' do
    let(:released_web_book) { create(:web_book, released: true) }
    let(:not_released_web_book) { create(:web_book, released: false) }

    it 'web books whose released is false are not published' do
      expect(described_class.released).to include released_web_book
      expect(described_class.released).not_to include not_released_web_book
    end
  end

  describe '#principal_author_names' do
    let(:old_author) { create(:author, name: 'old_name') }
    let(:new_author) { create(:author, name: 'new_name') }
    let(:web_book) { create(:web_book) }

    before do
      create(:web_book_author, author: old_author, web_book: web_book)
      create(:web_book_author, author: new_author, web_book: web_book)
    end

    it 'sort in ascending order of web_book_author id' do
      expect(web_book.principal_author_names).to eq 'old_name、new_name'
    end
  end

  describe '#price_including_tax' do
    context 'with not odd price' do
      let(:web_book) { create(:web_book, price: 1000) }

      it 'display price including tax' do
        expect(web_book.price_including_tax).to eq 1100
      end
    end

    context 'with odd price' do
      let(:web_book) { create(:web_book, price: 1001) }

      it 'display price including tax rounded down' do
        expect(web_book.price_including_tax).to eq 1101
      end
    end
  end

  describe '#deletable?' do
    let(:web_book) { create(:web_book, released: released) }

    context 'released web_book with purchase_record' do
      let(:released)  { true }

      before { create(:purchase_record, web_book: web_book) }

      it 'return false' do
        expect(web_book.deletable?).to eq false
      end
    end

    context 'not released web_book with purchase_record' do
      let(:released) { false }

      before { create(:purchase_record, web_book: web_book) }

      it 'return false' do
        expect(web_book.deletable?).to eq false
      end
    end

    context 'released web_book without purchase_record' do
      let(:released) { true }

      it 'return false' do
        expect(web_book.deletable?).to eq false
      end
    end

    context 'not released web_book without purchase_record' do
      let(:released) { false }

      it 'return true' do
        expect(web_book.deletable?).to eq true
      end
    end
  end

  describe '#not_release_without_pages' do
    let(:web_book) do
      WebBook.new(
        title: 'title',
        release_date: '2022-01-01',
        price: 1000, description: 'description',
        released: released,
        cover_image: Rack::Test::UploadedFile.new(Rails.root.join('spec/support/no_image.jpg'))
      )
    end

    context 'released web_book without pages' do
      let(:released) { true }

      it 'do not save web_book' do
        expect { web_book.save }.to change(WebBook, :count).by(0)
        expect(web_book.errors.full_messages).to eq ['ページのないWebブックは公開できません']
      end
    end

    context 'not released web_book without pages' do
      let(:released) { false }

      it 'save web_book' do
        expect { web_book.save }.to change(WebBook, :count).by(1)
      end
    end

    context 'web_book with pages' do
      let(:released) { false }

      before do
        create(:page, web_book: web_book)
      end

      it 'change released of web_book' do
        expect { web_book.update(released: true); web_book.reload }.to change(web_book, :released).from(false).to(true)
      end
    end
  end

  describe '#not_delete_released_web_book' do
    let!(:web_book) { create(:web_book, released: released) }

    before do
      create(:page, web_book: web_book)
      create(:page, web_book: web_book)
      # before_save回避のためにFactoryBotで作られたページを削除
      Page.where(title: 'delete_title').destroy_all
    end

    context 'web_book is not released' do
      let(:released) { false }

      it 'can delete web_book' do
        expect { web_book.destroy }.to change(WebBook, :count).by(-1).and change(Page, :count).by(-2)
      end
    end

    context 'web_book is released' do
      let(:released) { true }

      it 'cannot delete web_book' do
        expect { web_book.destroy }.to change(WebBook, :count).by(0).and change(Page, :count).by(0)
        expect(web_book.errors.full_messages).to eq ['公開済みのWebブックは削除できません']
      end
    end
  end
end
