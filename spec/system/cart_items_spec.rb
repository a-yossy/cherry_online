require 'rails_helper'

RSpec.describe 'CartItem', type: :system do
  describe 'カート一覧ページにアクセスする' do
    context 'カートの中が空である' do
      it 'カートが空のページが表示される' do
        visit root_path
        find('.svg-inline--fa').click
        expect(page).to have_current_path cart_items_path, ignore_query: true
        expect(page).to have_content('カートは空です')
      end
    end

    context 'カートにWebブックが入っている' do
      let(:web_book_one) { create(:web_book, title: 'title_one', price: 3000, released: true) }
      let(:web_book_two) { create(:web_book, title: 'title_two', price: 4000, released: true) }
      let(:author_one) { create(:author, name: 'author_one') }
      let(:author_two) { create(:author, name: 'author_two') }

      before do
        create(:web_book_author, web_book: web_book_one, author: author_one)
        create(:web_book_author, web_book: web_book_one, author: author_two)
        create(:web_book_author, web_book: web_book_two, author: author_one)
        create(:web_book_author, web_book: web_book_two, author: author_two)
      end

      it 'カートの中身が表示される' do
        visit root_path
        browser = Capybara.current_session.driver.browser
        browser.manage.add_cookie name: Constants::WEB_BOOKS_IN_CART_COOKIE_NAME, value: JSON.generate([web_book_one.id, web_book_two.id])
        find('.svg-inline--fa').click
        # カートアイコンの横の数字
        expect(page).to have_content(2)
        expect(page).to have_current_path cart_items_path, ignore_query: true
        expect(page).to have_content('title_one')
        expect(page).to have_content('3,300円')
        expect(page).to have_content('title_two')
        expect(page).to have_content('4,400円')
        expect(page).to have_content('author_one、author_two')
        expect(page).to have_selector('img')
        expect(page).to have_button('削除')
        expect(page).to have_content('合計7,700円')
        expect(page).to have_button('注文する')
      end
    end

    context 'カートにWebブックがPER_PAGE冊より多く入っている' do
      let(:web_books) { create_list(:web_book, 11, price: 1000) }
      let(:author_one) { create(:author) }
      let(:author_two) { create(:author) }

      before do
        web_books.each do |web_book|
          create(:web_book_author, web_book: web_book, author: author_one)
          create(:web_book_author, web_book: web_book, author: author_two)
        end
      end

      it 'ページネーションした全てのページで合計金額が正しく表示される' do
        visit root_path
        browser = Capybara.current_session.driver.browser
        browser.manage.add_cookie name: Constants::WEB_BOOKS_IN_CART_COOKIE_NAME, value: JSON.generate(web_books.pluck(:id))
        find('.svg-inline--fa').click
        expect(page).to have_content('合計12,100円')
        # 画面のサイズが小さい場合テストに失敗するため記載
        Capybara.current_session.driver.browser.manage.window.resize_to(1280, 1600)
        click_link '次'
        expect(page).to have_content('合計12,100円')
      end
    end
  end

  describe 'カートにWebブックを追加する' do
    context 'Webブックが未発売' do
      let(:web_book) { create(:web_book, title: 'title', release_date: Time.zone.today + 2.days, released: true) }
      let(:author) { create(:author, name: 'author') }

      before { create(:web_book_author, web_book: web_book, author: author) }

      it '発売予定のボタンが表示される' do
        visit root_path
        click_link 'title'
        expect(page).to have_button('発売予定', disabled: true)
      end
    end

    context 'Webブックが発売中' do
      let(:web_book) { create(:web_book, title: 'title', release_date: Time.zone.today - 2.days, released: true, price: 2000) }
      let(:author) { create(:author, name: 'author') }

      before { create(:web_book_author, web_book: web_book, author: author) }

      it 'カートにWebブックが追加される' do
        visit cart_items_path
        expect(page).not_to have_content('title')
        # カートアイコンの横の数字
        expect(page).not_to have_content(1)
        visit root_path
        click_link 'title'
        click_button 'カートに入れる'
        expect(page).to have_content(I18n.t('cart_items.create.success'))
        expect(page).to have_current_path web_book_path(web_book), ignore_query: true
        expect(page).not_to have_button('カートに入れる')
        expect(page).to have_button('カートに追加済み', disabled: true)
        find('.svg-inline--fa').click
        # カートアイコンの横の数字
        expect(page).to have_content(1)
        expect(page).to have_content('title')
      end
    end

    context 'Webブックを購入済み' do
      let(:user) { create(:user) }
      let(:web_book) { create(:web_book, title: 'title', release_date: Time.zone.today - 2.days, released: true) }
      let(:author) { create(:author, name: 'author') }
      let(:order_detail) { create(:order_detail, user: user) }

      before do
        create(:web_book_author, web_book: web_book, author: author)
        create(:purchase_record, web_book: web_book, user: user, order_detail: order_detail)
        login_as(user, scope: :user)
      end

      it '購入済みのボタンが表示される' do
        visit root_path
        click_link 'title'
        expect(page).to have_button('購入済み', disabled: true)
      end
    end

    context 'カートに入っているWebブックを別タブで追加する' do
      let(:web_book) { create(:web_book, title: 'title', release_date: Time.zone.today - 2.days, released: true, price: 3000) }
      let(:author) { create(:author) }

      before { create(:web_book_author, web_book: web_book, author: author) }

      it 'カートにWebブックが追加されない' do
        visit root_path
        click_link 'title'
        # 別タブでカートにWebブックを追加する動作を実施
        browser = Capybara.current_session.driver.browser
        browser.manage.add_cookie name: Constants::WEB_BOOKS_IN_CART_COOKIE_NAME, value: JSON.generate([web_book.id])
        click_button 'カートに入れる'
        expect(page).to have_content(I18n.t('cart_items.create.danger'))
        expect(page).to have_current_path web_book_path(web_book), ignore_query: true
        expect(page).to have_button('カートに追加済み', disabled: true)
        find('.svg-inline--fa').click
        expect(page).to have_content('title')
        expect(page).to have_content('3,300円')
        # カートアイコンの横の数字
        expect(page).to have_content(1)
        # 同じ本が2冊カートに入っていないことを検証
        expect(page).not_to have_content('合計6,600円')
      end
    end
  end

  describe 'カートからWebブックを削除する' do
    let(:web_book) { create(:web_book, title: 'title', release_date: Time.zone.now - 2.days, released: true) }
    let(:author) { create(:author, name: 'author') }

    before { create(:web_book_author, web_book: web_book, author: author) }

    it 'カートからWebブックが削除される' do
      visit root_path
      browser = Capybara.current_session.driver.browser
      browser.manage.add_cookie name: Constants::WEB_BOOKS_IN_CART_COOKIE_NAME, value: JSON.generate([web_book.id])
      find('.svg-inline--fa').click
      # カートアイコンの横の数字
      expect(page).to have_content(1)
      expect(page).to have_content('title')
      click_button '削除'
      expect(page).to have_content(I18n.t('cart_items.destroy.success'))
      expect(page).to have_current_path cart_items_path, ignore_query: true
      expect(page).to have_content('カートは空です')
      # カートアイコンの横の数字
      expect(page).not_to have_content(1)
      expect(page).not_to have_content('title')
    end
  end
end
