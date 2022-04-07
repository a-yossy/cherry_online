require 'rails_helper'
RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.describe OrderDetail, type: :model do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:total_amount) }
    it { is_expected.to validate_numericality_of(:total_amount).is_greater_than_or_equal_to(0) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:purchase_records).dependent(:destroy) }
    it { is_expected.to belong_to(:user).optional }
  end

  describe '#order_web_books' do
    let(:user) { create(:user) }

    context 'web books are not empty array and user does not have the same web book' do
      let(:web_book_one) { create(:web_book, price: 1000) }
      let(:web_book_two) { create(:web_book, price: 2000) }

      it 'create one order detail and two purchase records' do
        expect { OrderDetail.order_web_books([web_book_one, web_book_two], user) }.
          to change(OrderDetail, :count).by(1).
          and change(PurchaseRecord, :count).by(2)
        expect(OrderDetail.last.total_amount).to eq 3300
      end

      it 'return true' do
        expect(OrderDetail.order_web_books([web_book_one, web_book_two], user)).to eq true
      end
    end

    context 'web books are not empty array and user has the same web book' do
      let(:web_book) { create(:web_book) }
      let(:order_detail) { create(:order_detail, user: user) }

      before { create(:purchase_record, user: user, web_book: web_book, order_detail: order_detail) }

      it 'do not create order detail and purchase record' do
        expect { OrderDetail.order_web_books([web_book.id], user) }.
          to not_change(OrderDetail, :count).
          and not_change(PurchaseRecord, :count)
        expect(OrderDetail.order_web_books([web_book.id], user)).to eq false
      end
    end

    context 'web books are empty array' do
      it 'do not create order detail and purchase record' do
        expect { OrderDetail.order_web_books([], user) }.
          to not_change(OrderDetail, :count).
          and not_change(PurchaseRecord, :count)
        expect(OrderDetail.order_web_books([], user)).to eq false
      end
    end
  end

  describe 'recently_ordered' do
    let(:user) { create(:user) }
    let!(:old_order_detail) { create(:order_detail, user: user) }
    let(:new_order_detail) { create(:order_detail, user: user) }

    it 'sort in descending order of id' do
      expect(described_class.recently_ordered).to eq [new_order_detail, old_order_detail]
    end
  end
end
