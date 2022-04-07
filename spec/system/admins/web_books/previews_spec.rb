require 'rails_helper'

RSpec.describe 'Preview', type: :system do
  describe '表紙を読む' do
    let(:web_book) { create(:web_book, title: 'title') }
    let(:author) { create(:author, name: 'author') }

    before do
      create(:web_book_author, web_book: web_book, author: author)
      create(:page, title: 'page_title', web_book: web_book)
    end

    context '管理者がログインしている' do
      let(:admin) { create(:admin) }

      before { login_as(admin) }

      it '表紙を読むことができる' do
        visit admins_web_book_path(web_book)
        click_link 'この本を読む'
        expect(page).to have_current_path admins_web_book_preview_path(web_book), ignore_query: true
        expect(page).to have_content('表紙')
        expect(page).to have_content('title')
        expect(page).to have_content('author')
        expect(page).to have_selector('img')
        expect(page).to have_content('page_title')
      end
    end

    context '管理者がログインしていない' do
      it 'ログインページが表示される' do
        visit admins_web_book_preview_path(web_book)
        expect(page).to have_current_path new_admin_session_path, ignore_query: true
        expect(page).to have_content('Log in')
      end
    end
  end
end
