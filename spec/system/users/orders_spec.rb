require 'rails_helper'

RSpec.describe 'Order', type: :system do
  describe 'Webブックを注文する' do
    let(:web_book_one) { create(:web_book, title: 'web_book_one') }
    let(:web_book_two) { create(:web_book, title: 'web_book_two') }
    let(:author) { create(:author) }

    before do
      create(:web_book_author, web_book: web_book_one, author: author)
      create(:web_book_author, web_book: web_book_two, author: author)
    end

    context 'ユーザーがログインしている' do
      let(:user) { create(:user, name: 'name', email: 'example@email.com') }

      before { login_as(user, scope: :user) }

      it '注文が完了する' do
        visit root_path
        browser = Capybara.current_session.driver.browser
        browser.manage.add_cookie name: Constants::WEB_BOOKS_IN_CART_COOKIE_NAME, value: JSON.generate([web_book_one.id, web_book_two.id])
        find('.svg-inline--fa').click
        expect(page).to have_content('web_book_one')
        expect(page).to have_content('web_book_two')
        expect do
          click_button '注文する'
          expect(page).to have_content(I18n.t('users.orders.create.success'))
        end.to change(OrderDetail, :count).by(1).and change(PurchaseRecord, :count).by(2).and change(ActionMailer::Base.deliveries, :count).by(1)
        expect(ActionMailer::Base.deliveries.last.subject).to eq('【Cherry Online】注文完了のお知らせ')
        expect(ActionMailer::Base.deliveries.last.to).to eq(['example@email.com'])
        expect(ActionMailer::Base.deliveries.last.from).to eq(['attyan_cherry_online@example.com'])
        expect(page).to have_current_path root_path, ignore_query: true
        expect(page).to have_content('web_book_one')
        expect(page).to have_content('web_book_two')
        find('.svg-inline--fa').click
        expect(page).not_to have_content('web_book_one')
        expect(page).not_to have_content('web_book_two')
        expect(page).to have_content('カートは空です')
      end
    end

    context 'ユーザーがログインしていない' do
      it 'ログインページが表示される' do
        visit root_path
        browser = Capybara.current_session.driver.browser
        browser.manage.add_cookie name: Constants::WEB_BOOKS_IN_CART_COOKIE_NAME, value: JSON.generate([web_book_one.id, web_book_two.id])
        find('.svg-inline--fa').click
        expect(page).to have_content('web_book_one')
        expect(page).to have_content('web_book_two')
        expect do
          click_button '注文する'
          expect(page).to have_content(I18n.t('devise.failure.unauthenticated'))
        end.to change(OrderDetail, :count).by(0).and change(PurchaseRecord, :count).by(0).and change(ActionMailer::Base.deliveries, :count).by(0)
        expect(page).to have_current_path new_user_session_path, ignore_query: true
        expect(page).to have_content('ログイン')
        find('.svg-inline--fa').click
        expect(page).to have_content('web_book_one')
        expect(page).to have_content('web_book_two')
      end
    end

    context '購入済みのWebブックをログインせずにカートに追加する' do
      let(:web_book) { create(:web_book, title: 'title') }
      let(:author) { create(:author) }
      let(:order_detail) { create(:order_detail, total_amount: web_book.price) }
      let(:user) { create(:user, email: 'example@email.com', password: 'password') }

      before { create(:purchase_record, web_book: web_book, user: user, order_detail: order_detail) }

      it '注文が完了しない' do
        visit root_path
        click_link 'title'
        click_button 'カートに入れる'
        find('.svg-inline--fa').click
        expect(page).to have_content('title')
        expect(page).not_to have_content('購入済み')
        click_link 'ログイン'
        fill_in I18n.t('activerecord.attributes.user.email'), with: 'example@email.com'
        fill_in I18n.t('activerecord.attributes.user.password'), with: 'password'
        click_button 'ログイン'
        find('.svg-inline--fa').click
        expect(page).to have_content('title')
        expect(page).to have_content('購入済み')
        expect do
          click_button '注文する'
          expect(page).to have_content(I18n.t('users.orders.create.danger'))
        end.to change(OrderDetail, :count).by(0).and change(PurchaseRecord, :count).by(0).and change(ActionMailer::Base.deliveries, :count).by(0)
        expect(page).to have_current_path root_path, ignore_query: true
        expect(page).to have_content('title')
        find('.svg-inline--fa').click
        expect(page).to have_content('title')
        expect(page).to have_content('購入済み')
      end
    end
  end
end
