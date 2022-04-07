require 'rails_helper'
RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.describe WebBookForm, type: :model do
  describe '#releasable?' do
    let(:web_book) { create(:web_book, released: false) }
    let(:web_book_form) { described_class.new(web_book: web_book) }

    before do
      create(:web_book_author, web_book: web_book)
      # before_save回避のためにFactoryBotで作られたページを削除
      Page.where(title: 'delete_title').destroy_all
    end

    context 'with page' do
      before { create(:page, web_book: web_book) }

      it 'return true' do
        expect(web_book_form.releasable?).to eq true
      end
    end

    context 'without page' do
      it 'return false' do
        expect(web_book_form.releasable?).to eq false
      end
    end
  end

  describe '#save' do
    let(:web_book_form) do
      described_class.new({
                            title: 'title',
                            release_date: '2022-01-01',
                            price: 1000, description: 'description',
                            released: false,
                            cover_image: cover_image,
                            authors_attributes: authors_attributes
                          })
    end

    context 'when web_book_form has authors' do
      let(:cover_image) { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/no_image.jpg')) }
      let(:authors_attributes) do
        {
          '0': { name: 'existed_author' },
          '1': { name: 'author1' },
          '2': { name: 'author2' },
          '3': { name: '' },
          '4': { name: '' },
        }
      end

      before { create(:author, name: 'existed_author') }

      it 'creates one web_book and two authors and three web_book_authors' do
        expect { web_book_form.save }.to change(WebBook, :count).by(1).and change(Author, :count).by(2).and change(WebBookAuthor, :count).by(3)
        expect(web_book_form.web_book).to eq WebBook.last
      end

      it 'returns true' do
        expect(web_book_form.save).to be_truthy
      end
    end

    context 'when web_book_form has authors and does not have cover_image' do
      let(:cover_image) { nil }
      let(:authors_attributes) do
        {
          '0': { name: 'author' },
          '1': { name: '' },
          '2': { name: '' },
          '3': { name: '' },
          '4': { name: '' },
        }
      end

      it 'does not create web_books and authors' do
        expect { web_book_form.save }.to change(WebBook, :count).by(0).and change(Author, :count).by(0).and change(WebBookAuthor, :count).by(0)
        expect(web_book_form.save).to be_falsey
      end
    end

    context 'when web_book_form does not have authors' do
      let(:cover_image) { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/no_image.jpg')) }
      let(:authors_attributes) do
        {
          '0': { name: '' },
          '1': { name: '' },
          '2': { name: '' },
          '3': { name: '' },
          '4': { name: '' },
        }
      end

      it 'does not create web_books and authors' do
        expect { web_book_form.save }.to change(WebBook, :count).by(0).and change(Author, :count).by(0).and change(WebBookAuthor, :count).by(0)
        expect(web_book_form.save).to be_falsey
      end
    end

    context 'when web_book_form has the same authors' do
      let(:cover_image) { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/no_image.jpg')) }
      let(:authors_attributes) do
        {
          '0': { name: 'author' },
          '1': { name: 'author' },
          '2': { name: '' },
          '3': { name: '' },
          '4': { name: '' },
        }
      end

      it 'does not create web_books and authors' do
        expect { web_book_form.save }.to change(WebBook, :count).by(0).and change(Author, :count).by(0).and change(WebBookAuthor, :count).by(0)
        expect(web_book_form.save).to be_falsey
      end
    end
  end

  describe '#save act as #update' do
    let(:web_book) { create(:web_book, title: 'old_title', cover_image: Rack::Test::UploadedFile.new(Rails.root.join('spec/support/no_image.jpg'))) }
    let(:author1) { create(:author, name: 'author1') }
    let(:author2) { create(:author, name: 'author2') }
    let(:web_book_form) do
      described_class.new({
                            title: 'new_title',
                            release_date: '2022-03-31',
                            price: 2000,
                            description: '# update_description',
                            released: false,
                            cover_image: cover_image,
                            authors_attributes: authors_attributes,
                          },
                          web_book: web_book)
    end

    before do
      create(:web_book_author, web_book: web_book, author: author1)
      create(:web_book_author, web_book: web_book, author: author2)
    end

    context 'when web_book_form has authors' do
      let(:cover_image) { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/no_image.jpg')) }
      let(:authors_attributes) do
        {
          '0': { name: 'author1' },
          '1': { name: 'author2' },
          '2': { name: 'author3' },
          '3': { name: '' },
          '4': { name: '' },
        }
      end

      it 'changes the title and the authors of the web_book' do
        expect { web_book_form.save; web_book.reload }.
          to change(WebBook, :count).by(0).
          and change(Author, :count).by(1).
          and change(WebBookAuthor, :count).by(1).
          and change(web_book, :title).from('old_title').to('new_title')
        expect(web_book_form.save).to be_truthy
      end
    end

    context 'when web_book_form has authors and does not have new cover_image' do
      let(:cover_image) { nil }
      let(:authors_attributes) do
        {
          '0': { name: 'author1' },
          '1': { name: 'author2' },
          '2': { name: '' },
          '3': { name: '' },
          '4': { name: '' },
        }
      end

      it 'changes the title and does not change the cover_image of the web_book' do
        expect { web_book_form.save; web_book.reload }.
          to change(WebBook, :count).by(0).
          and change(Author, :count).by(0).
          and change(WebBookAuthor, :count).by(0).
          and change(web_book, :title).from('old_title').to('new_title').
          and not_change(web_book, :cover_image)
        expect(web_book_form.save).to be_truthy
      end
    end

    context 'when web_book_form has authors and new cover_image' do
      let(:cover_image) { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/new_image.png')) }
      let(:authors_attributes) do
        {
          '0': { name: 'author1' },
          '1': { name: 'author2' },
          '2': { name: '' },
          '3': { name: '' },
          '4': { name: '' },
        }
      end

      it 'changes the title and the cover_image of the web_book' do
        expect { web_book_form.save; web_book.reload }.
          to change(WebBook, :count).by(0).
          and change(Author, :count).by(0).
          and change(WebBookAuthor, :count).by(0).
          and change(web_book, :title).from('old_title').to('new_title').
          and change(web_book.cover_image, :filename)
        expect(web_book_form.save).to be_truthy
      end
    end

    context 'when web_book_form has smaller number of authors' do
      let(:cover_image) { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/no_image.jpg')) }
      let(:authors_attributes) do
        {
          '0': { name: 'author1' },
          '1': { name: '' },
          '2': { name: '' },
          '3': { name: '' },
          '4': { name: '' },
        }
      end

      it 'changes the title and reduces the number of authors' do
        expect { web_book_form.save; web_book.reload }.
          to change(WebBook, :count).by(0).
          and change(Author, :count).by(0).
          and change(WebBookAuthor, :count).by(-1).
          and change(web_book, :title).from('old_title').to('new_title')
        expect(web_book_form.save).to be_truthy
      end
    end

    context 'when web_book_form does not have authors' do
      let(:cover_image) { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/no_image.jpg')) }
      let(:authors_attributes) do
        {
          '0': { name: '' },
          '1': { name: '' },
          '2': { name: '' },
          '3': { name: '' },
          '4': { name: '' },
        }
      end

      it 'does not change the title and the authors of the web_book' do
        expect { web_book_form.save; web_book.reload }.
          to change(WebBook, :count).by(0).
          and change(Author, :count).by(0).
          and change(WebBookAuthor, :count).by(0)
        expect { web_book_form.save; web_book.reload }.not_to change(web_book, :title)
        expect(web_book_form.save).to be_falsey
      end
    end

    context 'when web_book_form has the same authors' do
      let(:cover_image) { Rack::Test::UploadedFile.new(Rails.root.join('spec/support/no_image.jpg')) }
      let(:authors_attributes) do
        {
          '0': { name: 'author' },
          '1': { name: 'author' },
          '2': { name: '' },
          '3': { name: '' },
          '4': { name: '' },
        }
      end

      it 'does not change the title and the authors of the web_book' do
        expect { web_book_form.save; web_book.reload }.
          to change(WebBook, :count).by(0).
          and change(Author, :count).by(0).
          and change(WebBookAuthor, :count).by(0)
        expect { web_book_form.save; web_book.reload }.not_to change(web_book, :title)
        expect(web_book_form.save).to be_falsey
      end
    end
  end
end
