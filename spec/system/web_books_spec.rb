require 'rails_helper'

RSpec.describe 'WebBook', type: :system do
  describe 'TOPページにアクセスする' do
    let(:released_web_book) { create(:web_book, title: 'released_title', released: true) }
    let(:not_released_web_book) { create(:web_book, title: 'not_released_title', released: true) }
    let(:author1) { create(:author, name: 'author1') }
    let(:author2) { create(:author, name: 'author2') }

    before do
      create(:web_book_author, web_book: released_web_book, author: author1)
      create(:web_book_author, web_book: released_web_book, author: author2)
      create(:web_book_author, web_book: not_released_web_book, author: author1)
    end

    it 'TOPページが表示される' do
      visit root_path
      expect(page).to have_content('TOPページ')
      expect(page).to have_content('released_title')
      expect(page).to have_content('author1')
      expect(page).to have_content('author2')
      expect(page).to have_content('not_released_title')
      not_released_web_book.update(released: false)
      visit root_path
      expect(page).not_to have_content('not_released_title')
    end
  end

  describe 'Webブック詳細ページにアクセスする' do
    context '公開フラグがtrueになっている' do
      let(:web_book) { create(:web_book, title: 'title', description: '# description', release_date: Time.zone.now - 2.days, released: true) }
      let(:author1) { create(:author, name: 'author1') }
      let(:author2) { create(:author, name: 'author2') }

      before do
        create(:web_book_author, web_book: web_book, author: author1)
        create(:web_book_author, web_book: web_book, author: author2)
        create(:page, title: 'page_title', web_book: web_book)
        # before_save回避のためにFactoryBotで作られたページを削除
        Page.where(title: 'delete_title').destroy_all
      end

      it 'Webブック詳細ページが表示される' do
        visit root_path
        click_link 'title'
        expect(page).to have_current_path web_book_path(web_book), ignore_query: true
        expect(page).to have_content('title')
        expect(page).to have_content('author1')
        expect(page).to have_content('author2')
        expect(page).to have_button('カートに入れる')
        expect(page).to have_content('description')
        expect(page).to have_content('1ページ')
        expect(page).to have_content('page_title')
      end
    end

    context '公開フラグがfalseになっている' do
      let(:web_book) { create(:web_book, title: 'title', description: '# description', released: false) }
      let(:author1) { create(:author, name: 'author1') }
      let(:author2) { create(:author, name: 'author2') }

      before do
        create(:web_book_author, web_book: web_book, author: author1)
        create(:web_book_author, web_book: web_book, author: author2)
        create(:page, title: 'page_title', web_book: web_book)
      end

      it 'Webブック詳細ページが表示されない' do
        visit web_book_path(web_book)
        expect(page).to have_content('お探しのページは見つかりません')
        expect(page).not_to have_content('title')
        expect(page).not_to have_content('author1')
        expect(page).not_to have_content('author2')
        expect(page).not_to have_button('カートに入れる')
        expect(page).not_to have_content('description')
        expect(page).not_to have_content('1ページ')
        expect(page).not_to have_content('page_title')
      end
    end
  end
end
