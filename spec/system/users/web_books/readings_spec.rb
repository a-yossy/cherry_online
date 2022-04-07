require 'rails_helper'

RSpec.describe 'Reading', type: :system do
  describe '表紙を読む' do
    let(:web_book) { create(:web_book, title: 'title', released: true) }
    let(:author) { create(:author, name: 'author') }

    before do
      create(:web_book_author, web_book: web_book, author: author)
      create(:page, title: 'page_title', web_book: web_book)
    end

    context 'ユーザーがログインしている' do
      let(:user) { create(:user) }

      before { login_as(user, scope: :user) }

      context 'Webブックを購入済み' do
        let(:order_detail) { create(:order_detail, user: user, paid: true) }

        before { create(:purchase_record, user: user, web_book: web_book, order_detail: order_detail) }

        it '表紙を読むことができる' do
          visit users_web_books_path
          click_link 'この本を読む'
          expect(page).to have_current_path users_web_book_reading_path(web_book), ignore_query: true
          expect(page).to have_content('表紙')
          expect(page).to have_content('title')
          expect(page).to have_content('author')
          expect(page).to have_selector('img')
          expect(page).to have_content('page_title')
        end
      end

      context 'Webブックを未注文' do
        it '表紙を読むことができない' do
          visit users_web_book_reading_path(web_book)
          expect(page).to have_content('お探しのページは見つかりません')
        end
      end

      context 'Webブックを注文済みかつ未購入' do
        let(:order_detail) { create(:order_detail, user: user, paid: false) }

        before { create(:purchase_record, user: user, web_book: web_book, order_detail: order_detail) }

        it '表紙を読むことができない' do
          visit users_web_book_reading_path(web_book)
          expect(page).to have_content('お探しのページは見つかりません')
        end
      end

      context 'Webブックを未注文で、他のユーザーが購入済み' do
        let(:other_user) { create(:user) }
        let(:other_user_order_detail) { create(:order_detail, user: other_user, paid: true) }

        before { create(:purchase_record, user: other_user, web_book: web_book, order_detail: other_user_order_detail) }

        it '表紙を読むことができない' do
          visit users_web_book_reading_path(web_book)
          expect(page).to have_content('お探しのページは見つかりません')
        end
      end

      context 'Webブックを注文済みかつ未購入で、他のユーザーが購入済み' do
        let(:other_user) { create(:user) }
        let(:user_order_detail) { create(:order_detail, user: user, paid: false) }
        let(:other_user_order_detail) { create(:order_detail, user: other_user, paid: true) }

        before do
          create(:purchase_record, user: user, web_book: web_book, order_detail: user_order_detail)
          create(:purchase_record, user: other_user, web_book: web_book, order_detail: other_user_order_detail)
        end

        it '表紙を読むことができない' do
          visit users_web_book_reading_path(web_book)
          expect(page).to have_content('お探しのページは見つかりません')
        end
      end

      context 'Webブックの公開フラグがfalse' do
        let(:order_detail) { create(:order_detail, user: user, paid: true) }

        before { create(:purchase_record, user: user, web_book: web_book, order_detail: order_detail) }

        it '表紙を読むことができる' do
          web_book.update(released: false)
          visit users_web_books_path
          click_link 'この本を読む'
          expect(page).to have_current_path users_web_book_reading_path(web_book), ignore_query: true
          expect(page).to have_content('表紙')
          expect(page).to have_content('title')
          expect(page).to have_content('author')
          expect(page).to have_selector('img')
          expect(page).to have_content('page_title')
        end
      end
    end

    context 'ユーザーがログインしていない' do
      it 'ログインページが表示される' do
        visit users_web_book_reading_path(web_book)
        expect(page).to have_current_path new_user_session_path, ignore_query: true
        expect(page).to have_content('ログイン')
      end
    end
  end
end
