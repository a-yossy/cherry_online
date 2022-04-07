require 'rails_helper'

RSpec.describe 'OrderDetail', type: :system do
  describe '注文明細一覧にアクセスする' do
    context '管理者がログインしている' do
      let(:admin) { create(:admin) }
      let(:user) { create(:user, name: 'name') }
      let!(:order_detail) { create(:order_detail, id: 3, total_amount: 2000, paid: false, user: user, created_at: Time.zone.parse('2022-01-01-00-00-00')) }

      before { login_as(admin) }

      context '決済状況の絞り込みを行わない' do
        it '注文明細一覧が表示される' do
          visit root_path
          click_link '注文明細'
          expect(page).to have_current_path admins_order_details_path, ignore_query: true
          expect(page).to have_content(3)
          expect(page).to have_content('2022/01/01 00:00:00')
          expect(page).to have_content('name')
          expect(page).to have_content('2,000円')
          expect(page).to have_button('決済を完了にする')
          within '#test-order-details-table' do
            expect(page).not_to have_content('完了')
          end
          order_detail.update(paid: true)
          visit admins_order_details_path
          expect(page).not_to have_button('決済を完了にする')
          within '#test-order-details-table' do
            expect(page).to have_content('完了')
          end
        end
      end

      context '決済状況の絞り込みを行う' do
        let(:paid_user) { create(:user, name: 'paid_user_name') }
        let(:unpaid_user) { create(:user, name: 'unpaid_name') }

        before do
          create(:order_detail, paid: true, user: paid_user)
          create(:order_detail, paid: false, user: unpaid_user)
        end

        it '決済状況で絞り込みが行われる' do
          visit root_path
          click_link '注文明細'
          expect(page).to have_content('paid_user_name')
          expect(page).to have_content('unpaid_name')
          select '完了', from: 'q[paid_eq]'
          click_button '検索'
          expect(page).to have_content('paid_user_name')
          expect(page).not_to have_content('unpaid_name')
          select '未完了', from: 'q[paid_eq]'
          click_button '検索'
          expect(page).not_to have_content('paid_user_name')
          expect(page).to have_content('unpaid_name')
        end
      end

      context 'ユーザーが退会済み' do
        it '注文明細一覧が表示され、購入者に"退会済み"と表示される' do
          order_detail.update(user: nil)
          visit root_path
          click_link '注文明細'
          expect(page).to have_current_path admins_order_details_path, ignore_query: true
          expect(page).to have_content(3)
          expect(page).to have_content('2022/01/01 00:00:00')
          expect(page).to have_content('退会済み')
          expect(page).to have_content('2,000円')
          expect(page).to have_button('決済を完了にする')
          within '#test-order-details-table' do
            expect(page).not_to have_content('完了')
          end
          order_detail.update(paid: true)
          visit admins_order_details_path
          expect(page).not_to have_button('決済を完了にする')
          within '#test-order-details-table' do
            expect(page).to have_content('完了')
          end
        end
      end
    end

    context '管理者がログインしていない' do
      it 'ログインページが表示される' do
        visit admins_order_details_path
        expect(page).to have_current_path new_admin_session_path, ignore_query: true
        expect(page).to have_content('Log in')
      end
    end
  end

  describe '注文明細の詳細にアクセスする' do
    let(:user) { create(:user, name: 'name') }
    let(:web_book_one) { create(:web_book, id: 1, title: 'title_one', price: 3000) }
    let(:web_book_two) { create(:web_book, id: 2, title: 'title_two', price: 4000) }
    let(:order_detail) { create(:order_detail, id: 5, user: user) }

    before do
      create(:purchase_record, web_book: web_book_one, user: user, order_detail: order_detail)
      create(:purchase_record, web_book: web_book_two, user: user, order_detail: order_detail)
    end

    context '管理者がログインしている' do
      let(:admin) { create(:admin) }

      before { login_as(admin) }

      it '注文明細の詳細が表示される' do
        visit admins_order_details_path
        click_link '注文の詳細を表示'
        expect(page).to have_content('注文番号: 5')
        expect(page).to have_content(1)
        expect(page).to have_content('title_one')
        expect(page).to have_content('3,300円')
        expect(page).to have_content(2)
        expect(page).to have_content('title_two')
        expect(page).to have_content('4,400円')
      end
    end

    context '管理者がログインしていない' do
      it 'ログインページが表示される' do
        visit admins_order_detail_path(order_detail)
        expect(page).to have_current_path new_admin_session_path, ignore_query: true
        expect(page).to have_content('Log in')
      end
    end
  end

  describe '決済状況を完了にする' do
    let(:admin) { create(:admin) }
    let(:user) { create(:user, email: 'example@email.com') }
    let!(:order_detail) { create(:order_detail, paid: false, user: user) }

    before { login_as(admin) }

    context '決済状況が未完了である' do
      it '決済状況が完了になる' do
        visit admins_order_details_path
        click_button '決済を完了にする'
        expect do
          expect(page.accept_confirm).to eq '本当に変更しますか?'
          expect(page).to have_content(I18n.t('admins.order_details.update.success'))
          order_detail.reload
        end.to change(order_detail, :paid).from(false).to(true).and change(ActionMailer::Base.deliveries, :count).by(1)
        expect(ActionMailer::Base.deliveries.last.subject).to eq('【Cherry Online】購入完了のお知らせ')
        expect(ActionMailer::Base.deliveries.last.to).to eq(['example@email.com'])
        expect(ActionMailer::Base.deliveries.last.from).to eq(['attyan_cherry_online@example.com'])
        within '#test-order-details-table' do
          expect(page).to have_content('完了')
        end
        expect(page).not_to have_button('決済を完了にする')
      end
    end

    context '決済状況が未完了でユーザーが退会済み' do
      it '決済状況が完了になる' do
        order_detail.update(user: nil)
        visit admins_order_details_path
        click_button '決済を完了にする'
        expect do
          expect(page.accept_confirm).to eq '本当に変更しますか?'
          expect(page).to have_content(I18n.t('admins.order_details.update.success'))
          order_detail.reload
        end.to change(order_detail, :paid).from(false).to(true).and change(ActionMailer::Base.deliveries, :count).by(0)
        within '#test-order-details-table' do
          expect(page).to have_content('完了')
        end
        expect(page).not_to have_button('決済を完了にする')
      end
    end

    context '決済状況が完了である' do
      it 'ユーザーにメールが送信されない' do
        visit admins_order_details_path
        # 別タブで'決済を完了にする'ボタンをクリック
        order_detail.update(paid: true)
        click_button '決済を完了にする'
        expect do
          expect(page.accept_confirm).to eq '本当に変更しますか?'
          expect(page).to have_content(I18n.t('admins.order_details.update.danger'))
        end.not_to change(ActionMailer::Base.deliveries, :count)
        within '#test-order-details-table' do
          expect(page).to have_content('完了')
        end
        expect(page).not_to have_button('決済を完了にする')
      end
    end
  end
end
