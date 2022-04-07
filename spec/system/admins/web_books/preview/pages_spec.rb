require 'rails_helper'

RSpec.describe 'PreviewPage', type: :system do
  describe 'Webブックのページを読む' do
    let(:web_book) { create(:web_book, title: 'title') }
    let(:author) { create(:author, name: 'author') }
    let!(:web_book_page) { create(:page, title: 'page_title', body: '# body', web_book: web_book) }

    before { create(:web_book_author, web_book: web_book, author: author) }

    context '管理者がログインしている' do
      let(:admin) { create(:admin) }

      before { login_as(admin) }

      it 'Webブックのページを読むことができる' do
        visit admins_web_book_path(web_book)
        click_link 'この本を読む'
        expect(page).to have_content('表紙')
        expect(page).to have_content('page_title')
        click_link 'page_title'
        expect(page).to have_current_path admins_web_book_preview_page_path(web_book, web_book_page), ignore_query: true
        expect(page).to have_content('表紙')
        expect(page).to have_content('page_title')
        expect(page).to have_content('body')
      end
    end

    context '管理者がログインしていない' do
      it 'ログインページが表示される' do
        visit admins_web_book_preview_page_path(web_book, web_book_page)
        expect(page).to have_current_path new_admin_session_path, ignore_query: true
        expect(page).to have_content('Log in')
      end
    end
  end
end
