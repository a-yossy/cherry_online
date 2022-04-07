require 'rails_helper'

RSpec.describe PurchaseRecord, type: :model do
  describe 'validations' do
    describe 'uniqueness with web_book and user' do
      subject do
        purchase_record.valid?
        purchase_record.errors
      end

      let(:user) { create(:user) }
      let(:purchase_record) { build(:purchase_record, user: user, web_book: web_book) }
      let(:existed_web_book) { create(:web_book, title: 'existed_web_book') }

      before { create(:purchase_record, user: user, web_book: existed_web_book) }

      context 'with the same web book' do
        let(:web_book) { WebBook.find_by(title: 'existed_web_book') }

        it { is_expected.to be_of_kind(:web_book, :taken) }
      end

      context 'with not the same web book' do
        let(:web_book) { create(:web_book, title: 'title') }

        it { is_expected.not_to be_of_kind(:web_book, :taken) }
      end
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:web_book) }
    it { is_expected.to belong_to(:user).optional }
    it { is_expected.to belong_to(:order_detail).dependent(false) }
  end

  describe 'recently_ordered' do
    let!(:old_purchase_record) { create(:purchase_record) }
    let(:new_purchase_record) { create(:purchase_record) }

    it 'sort in descending order of id' do
      expect(described_class.recently_ordered).to eq [new_purchase_record, old_purchase_record]
    end
  end

  describe 'formerly_ordered' do
    let!(:old_purchase_record) { create(:purchase_record) }
    let(:new_purchase_record) { create(:purchase_record) }

    it 'sort in descending order of id' do
      expect(described_class.formerly_ordered).to eq [old_purchase_record, new_purchase_record]
    end
  end
end
