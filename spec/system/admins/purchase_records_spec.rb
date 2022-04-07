require 'rails_helper'

RSpec.describe 'PurchaseRecord', type: :system do
  describe '購入履歴一覧にアクセスする' do
    context '管理者がログインしている' do
      let(:admin) { create(:admin) }
      let(:web_book) { create(:web_book, title: 'title', price: 1000) }
      let(:user) { create(:user, name: 'name', email: 'example@email.com') }
      let(:order_detail) { create(:order_detail, user: user, paid: false, created_at: Time.zone.parse('2022-01-01-00-00-00')) }

      before do
        login_as(admin)
        create(:purchase_record, web_book: web_book, user: user, order_detail: order_detail)
      end

      it '購入履歴一覧が表示される' do
        visit root_path
        click_link '購入履歴'
        expect(page).to have_current_path admins_purchase_records_path, ignore_query: true
        expect(page).to have_content('title')
        expect(page).to have_content('2022/01/01 00:00:00')
        expect(page).to have_content('未完了')
        expect(page).to have_content('1,100円')
        expect(page).to have_content('example@email.com')
        expect(page).to have_content('name')
        expect(page).to have_content('未購入')
        order_detail.update(paid: true, updated_at: Time.zone.parse('2022-02-01-00-00-00'))
        visit(admins_purchase_records_path)
        expect(page).not_to have_content('未完了')
        expect(page).to have_content('完了')
        expect(page).not_to have_content('未購入')
        expect(page).to have_content('2022/02/01 00:00:00')
      end
    end

    context '管理者がログインしていない' do
      it 'ログインページが表示される' do
        visit admins_purchase_records_path
        expect(page).to have_current_path new_admin_session_path, ignore_query: true
        expect(page).to have_content('Log in')
      end
    end
  end
end
