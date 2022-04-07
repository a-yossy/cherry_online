require 'rails_helper'

RSpec.describe 'Session', type: :system do
  describe 'ユーザがログインする' do
    before { create(:user, name: 'user', email: 'example@email.com', password: 'password') }

    it 'ユーザがログインされる' do
      visit root_path
      expect(page).not_to have_link('user')
      expect(page).to have_link('新規登録')
      expect(page).to have_link('ログイン')
      click_link 'ログイン'
      expect(page).to have_current_path new_user_session_path, ignore_query: true
      # バリデーションエラーをテスト
      click_button 'ログイン'
      expect(page).to have_css('.alert.alert-warning')
      fill_in I18n.t('activerecord.attributes.user.email'), with: 'example@email.com'
      fill_in I18n.t('activerecord.attributes.user.password'), with: 'password'
      expect do
        click_button 'ログイン'
        expect(page).to have_content I18n.t('devise.sessions.signed_in')
      end.to change(User, :count).by(0)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_link('user')
      expect(page).not_to have_link('新規登録')
      expect(page).not_to have_link('ログイン')
    end
  end
end
