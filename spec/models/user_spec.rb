require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:purchase_records).dependent(:nullify) }
    it { is_expected.to have_many(:web_books).through(:purchase_records) }
    it { is_expected.to have_many(:order_details).dependent(:nullify) }
  end

  describe '#recently_ordered_paid_web_books' do
    context 'with other user' do
      let(:test_user) { create(:user) }
      let(:other_user) { create(:user) }
      let(:paid_test_user_web_book) { create(:web_book) }
      let(:unpaid_test_user_web_book) { create(:web_book) }
      let(:paid_other_user_web_book) { create(:web_book) }
      let(:paid_test_user_order_detail) { create(:order_detail, user: test_user, paid: true) }
      let(:unpaid_test_user_order_detail) { create(:order_detail, user: test_user, paid: false) }
      let(:paid_other_user_order_detail) { create(:order_detail, user: other_user, paid: true) }

      before do
        create(:purchase_record, user: test_user, web_book: paid_test_user_web_book, order_detail: paid_test_user_order_detail)
        create(:purchase_record, user: test_user, web_book: unpaid_test_user_web_book, order_detail: unpaid_test_user_order_detail)
        create(:purchase_record, user: other_user, web_book: paid_other_user_web_book, order_detail: paid_other_user_order_detail)
      end

      it 'display test user web books that are paid' do
        expect(test_user.recently_ordered_paid_web_books).to eq [paid_test_user_web_book]
      end
    end

    context 'without other user' do
      let(:test_user) { create(:user) }
      let(:paid_test_user_old_ordered_web_book) { create(:web_book) }
      let(:paid_test_user_new_ordered_web_book) { create(:web_book) }
      let(:paid_test_user_order_detail) { create(:order_detail, user: test_user, paid: true) }

      before do
        create(:purchase_record, id: 1, user: test_user, web_book: paid_test_user_old_ordered_web_book, order_detail: paid_test_user_order_detail)
        create(:purchase_record, id: 2, user: test_user, web_book: paid_test_user_new_ordered_web_book, order_detail: paid_test_user_order_detail)
      end

      it 'display test user web books sorted in descending order of purchase record id' do
        expect(test_user.recently_ordered_paid_web_books).to eq [paid_test_user_new_ordered_web_book, paid_test_user_old_ordered_web_book]
      end
    end
  end
end
