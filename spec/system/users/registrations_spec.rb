require 'rails_helper'

RSpec.describe 'Registration', type: :system do
  describe 'ユーザ登録をする' do
    it 'ユーザが登録され、ログインされる' do
      visit root_path
      expect(page).not_to have_link('user')
      expect(page).to have_link('新規登録')
      expect(page).to have_link('ログイン')
      click_link '新規登録'
      expect(page).to have_current_path new_user_registration_path, ignore_query: true
      # バリデーションエラーをテスト
      expect do
        click_button '新規登録'
        expect(page).to have_css('.alert.alert-warning')
      end.not_to change(User, :count)
      fill_in I18n.t('activerecord.attributes.user.name'), with: 'user'
      fill_in I18n.t('activerecord.attributes.user.email'), with: 'example@email.com'
      fill_in I18n.t('activerecord.attributes.user.password'), with: 'password'
      fill_in I18n.t('activerecord.attributes.user.password_confirmation'), with: 'password'
      expect do
        click_button '新規登録'
        expect(page).to have_content I18n.t('devise.registrations.signed_up')
      end.to change(User, :count).by(1)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_link('user')
      expect(page).not_to have_link('新規登録')
      expect(page).not_to have_link('ログイン')
    end
  end

  describe 'ユーザ情報を編集する' do
    let(:user) { create(:user, name: 'user', email: 'example@email.com', password: 'password') }

    before { login_as(user, scope: :user) }

    it 'ユーザ情報が編集される' do
      visit root_path
      click_link 'user'
      click_link '基本設定'
      expect(page).to have_current_path edit_user_registration_path, ignore_query: true
      # バリデーションエラーをテスト
      fill_in I18n.t('activerecord.attributes.user.name'), with: '', fill_options: { clear: :backspace }
      expect do
        click_button '更新する'
        expect(page).to have_css('.alert.alert-warning')
        user.reload
      end.not_to change(user, :name)
      fill_in I18n.t('activerecord.attributes.user.name'), with: 'new_user', fill_options: { clear: :backspace }
      fill_in I18n.t('activerecord.attributes.user.email'), with: 'new_example@email.com', fill_options: { clear: :backspace }
      fill_in I18n.t('activerecord.attributes.user.password'), with: 'new_password'
      fill_in I18n.t('activerecord.attributes.user.password_confirmation'), with: 'new_password'
      fill_in I18n.t('activerecord.attributes.admin.current_password'), with: 'password'
      expect do
        click_button '更新する'
        expect(page).to have_content I18n.t('devise.registrations.updated')
        user.reload
      end.
        to change(User, :count).by(0).
        and change(user, :name).from('user').to('new_user').
        and change(user, :email).from('example@email.com').to('new_example@email.com')
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).to have_link('new_user')
      expect(user.valid_password?('new_password')).to eq true
      expect(user.valid_password?('password')).to eq false
    end
  end

  describe 'ユーザを削除する' do
    let(:user) { create(:user, name: 'user') }

    before { login_as(user, scope: :user) }

    it 'ユーザが削除される' do
      visit root_path
      expect(page).to have_link('user')
      expect(page).not_to have_link('新規登録')
      expect(page).not_to have_link('ログイン')
      click_link 'user'
      click_link '基本設定'
      expect(page).to have_current_path edit_user_registration_path, ignore_query: true
      click_button 'アカウントを削除する'
      expect do
        expect(page.accept_confirm).to eq '本当に削除しますか?'
        expect(page).to have_content I18n.t('devise.registrations.destroyed')
      end.to change(User, :count).by(-1)
      expect(page).to have_current_path root_path, ignore_query: true
      expect(page).not_to have_link('user')
      expect(page).to have_link('新規登録')
      expect(page).to have_link('ログイン')
    end
  end
end
