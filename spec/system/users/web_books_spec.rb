require 'rails_helper'

RSpec.describe 'Users/WebBook', type: :system do
  describe 'TOPページにアクセスする' do
    context 'ユーザーがログインしている' do
      let(:user) { create(:user, name: 'user') }
      let(:web_book) { create(:web_book, title: 'title', released: true) }
      let(:author) { create(:author, name: 'author') }

      before do
        login_as(user, scope: :user)
        create(:web_book_author, web_book: web_book, author: author)
      end

      context 'Webブックを購入済み' do
        let(:order_detail) { create(:order_detail, user: user, paid: true) }

        before { create(:purchase_record, user: user, web_book: web_book, order_detail: order_detail) }

        it '"この本を読む"のリンクを持つWebブックが表示される' do
          visit root_path
          click_link 'user'
          click_link 'マイページ'
          expect(page).to have_current_path users_web_books_path, ignore_query: true
          expect(page).to have_content('マイページ')
          expect(page).to have_content('title')
          expect(page).to have_content('author')
          expect(page).to have_selector('img')
          expect(page).to have_link('この本を読む')
          expect(page).not_to have_button('決済未完了', disabled: true)
          web_book.update(released: false)
          visit users_web_books_path
          expect(page).to have_content('title')
          expect(page).to have_content('author')
          expect(page).to have_selector('img')
          expect(page).to have_link('この本を読む')
          expect(page).not_to have_button('決済未完了', disabled: true)
        end
      end

      context 'Webブックを未注文' do
        it 'Webブックが表示されない' do
          visit root_path
          click_link 'user'
          click_link 'マイページ'
          expect(page).to have_current_path users_web_books_path, ignore_query: true
          expect(page).to have_content('マイページ')
          expect(page).not_to have_content('title')
          expect(page).not_to have_content('author')
          expect(page).not_to have_selector('img')
          expect(page).not_to have_link('この本を読む')
        end
      end

      context 'Webブックを注文済みかつ未購入' do
        let(:order_detail) { create(:order_detail, user: user, paid: false) }

        before { create(:purchase_record, user: user, web_book: web_book, order_detail: order_detail) }

        it 'Webブックが表示されない' do
          visit root_path
          click_link 'user'
          click_link 'マイページ'
          expect(page).to have_current_path users_web_books_path, ignore_query: true
          expect(page).to have_content('マイページ')
          expect(page).not_to have_content('title')
          expect(page).not_to have_content('author')
          expect(page).not_to have_selector('img')
          expect(page).not_to have_link('この本を読む')
        end
      end

      context 'Webブックを未注文で、他のユーザーが購入済み' do
        let(:other_user) { create(:user) }
        let(:order_detail) { create(:order_detail, user: other_user, paid: true) }

        before { create(:purchase_record, user: other_user, web_book: web_book, order_detail: order_detail) }

        it 'Webブックが表示されない' do
          visit root_path
          click_link 'user'
          click_link 'マイページ'
          expect(page).to have_current_path users_web_books_path, ignore_query: true
          expect(page).to have_content('マイページ')
          expect(page).not_to have_content('title')
          expect(page).not_to have_content('author')
          expect(page).not_to have_selector('img')
          expect(page).not_to have_link('この本を読む')
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

        it 'Webブックが表示されない' do
          visit root_path
          click_link 'user'
          click_link 'マイページ'
          expect(page).to have_current_path users_web_books_path, ignore_query: true
          expect(page).to have_content('マイページ')
          expect(page).not_to have_content('title')
          expect(page).not_to have_content('author')
          expect(page).not_to have_selector('img')
          expect(page).not_to have_link('この本を読む')
        end
      end
    end

    context 'ユーザーがログインしていない' do
      it 'ログインページが表示される' do
        visit users_web_books_path
        expect(page).to have_current_path new_user_session_path, ignore_query: true
        expect(page).to have_content('ログイン')
      end
    end
  end
end
