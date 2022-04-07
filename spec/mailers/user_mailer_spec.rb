require 'rails_helper'

RSpec.describe UserMailer, type: :mailer do
  describe 'order_completion' do
    let(:user) { create(:user, name: 'name', email: 'example@email.com') }
    let(:web_book_one) { create(:web_book, title: 'title_one', price: 1000) }
    let(:web_book_two) { create(:web_book, title: 'title_two', price: 2000) }
    let(:mail) do
      described_class.with(
        name: user.name,
        email: user.email,
        order_date_and_time: Time.zone.parse('2022-01-01-00-00-00'),
        total_amount: [web_book_one, web_book_two].sum(&:price_including_tax),
        web_books: [web_book_one, web_book_two]
      ).order_completion
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('【Cherry Online】注文完了のお知らせ')
      expect(mail.to).to eq(['example@email.com'])
      expect(mail.from).to eq(['attyan_cherry_online@example.com'])
    end

    it 'renders the body with html' do
      expect(mail.html_part.body).to have_content('name')
      expect(mail.html_part.body).to have_content('title_one')
      expect(mail.html_part.body).to have_content('title_two')
      expect(mail.html_part.body).to have_content('1,100')
      expect(mail.html_part.body).to have_content('2,200')
      expect(mail.html_part.body).to have_content('3,300')
      expect(mail.html_part.body).to have_content('2022/01/01 00:00:00')
    end

    it 'renders the body with text' do
      expect(mail.text_part.body).to have_content('name')
      expect(mail.text_part.body).to have_content('title_one')
      expect(mail.text_part.body).to have_content('title_two')
      expect(mail.text_part.body).to have_content('1,100')
      expect(mail.text_part.body).to have_content('2,200')
      expect(mail.text_part.body).to have_content('3,300')
      expect(mail.text_part.body).to have_content('2022/01/01 00:00:00')
    end

    it 'sends the mail' do
      expect { mail.deliver_now }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end

  describe 'purchase_completion' do
    let(:user) { create(:user, name: 'name', email: 'example@email.com') }
    let(:web_book_one) { create(:web_book, title: 'title_one', price: 1000) }
    let(:web_book_two) { create(:web_book, title: 'title_two', price: 2000) }
    let(:order_detail) { create(:order_detail, total_amount: web_book_one.price_including_tax + web_book_two.price_including_tax, user: user) }
    let(:mail) do
      described_class.with(
        name: order_detail.user.name,
        email: order_detail.user.email,
        total_amount: order_detail.total_amount,
        purchase_date_and_time: Time.zone.parse('2022-01-01-00-00-00'),
        web_books: WebBook.find(order_detail.purchase_records.pluck(:web_book_id))
      ).purchase_completion
    end

    before do
      create(:purchase_record, web_book: web_book_one, user: user, order_detail: order_detail)
      create(:purchase_record, web_book: web_book_two, user: user, order_detail: order_detail)
    end

    it 'renders the headers' do
      expect(mail.subject).to eq('【Cherry Online】購入完了のお知らせ')
      expect(mail.to).to eq(['example@email.com'])
      expect(mail.from).to eq(['attyan_cherry_online@example.com'])
    end

    it 'renders the body with html' do
      expect(mail.html_part.body).to have_content('name')
      expect(mail.html_part.body).to have_content('title_one')
      expect(mail.html_part.body).to have_content('title_two')
      expect(mail.html_part.body).to have_content('1,100')
      expect(mail.html_part.body).to have_content('2,200')
      expect(mail.html_part.body).to have_content('3,300')
      expect(mail.html_part.body).to have_content('2022/01/01 00:00:00')
    end

    it 'renders the body with text' do
      expect(mail.text_part.body).to have_content('name')
      expect(mail.text_part.body).to have_content('title_one')
      expect(mail.text_part.body).to have_content('title_two')
      expect(mail.text_part.body).to have_content('1,100')
      expect(mail.text_part.body).to have_content('2,200')
      expect(mail.text_part.body).to have_content('3,300')
      expect(mail.text_part.body).to have_content('2022/01/01 00:00:00')
    end

    it 'sends the mail' do
      expect { mail.deliver_now }.to change(ActionMailer::Base.deliveries, :count).by(1)
    end
  end
end
