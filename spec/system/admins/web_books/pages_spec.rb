require 'rails_helper'
RSpec::Matchers.define_negated_matcher :not_change, :change

RSpec.describe 'Page', type: :system do
  describe 'Webブックのページ詳細ページにアクセスする' do
    let(:web_book) { create(:web_book, title: 'title') }
    let(:author) { create(:author) }
    let!(:web_book_page) { create(:page, title: 'page_title', body: '# body', web_book: web_book) }

    before { create(:web_book_author, web_book: web_book, author: author) }

    context '管理者がログインしている' do
      let(:admin) { create(:admin) }

      before { login_as(admin) }

      it 'Webブックのページ詳細ページが表示される' do
        visit admins_web_book_path(web_book)
        click_link 'page_title'
        expect(page).to have_current_path admins_web_book_page_path(web_book, web_book_page), ignore_query: true
        expect(page).to have_content('body')
        expect(page).to have_content('page_title')
      end
    end

    context '管理者がログインしていない' do
      it 'ログインページが表示される' do
        visit admins_web_book_page_path(web_book, web_book_page)
        expect(page).to have_current_path new_admin_session_path, ignore_query: true
        expect(page).to have_content('Log in')
      end
    end
  end

  describe 'Webブックのページ作成ページにアクセスする' do
    let(:web_book) { create(:web_book) }
    let(:author) { create(:author) }

    before { create(:web_book_author, web_book: web_book, author: author) }

    context '管理者がログインしている' do
      let(:admin) { create(:admin) }

      before { login_as(admin) }

      it 'Webブックのページ作成ページが表示される' do
        visit admins_web_book_path(web_book)
        click_link 'ページ追加'
        expect(page).to have_current_path new_admins_web_book_page_path(web_book), ignore_query: true
        expect(page).to have_field(I18n.t('activerecord.attributes.page.title'))
        expect(page).to have_field(I18n.t('activerecord.attributes.page.body'))
      end
    end

    context '管理者がログインしていない' do
      it 'ログインページが表示される' do
        visit new_admins_web_book_page_path(web_book)
        expect(page).to have_current_path new_admin_session_path, ignore_query: true
        expect(page).to have_content('Log in')
      end
    end
  end

  describe 'Webブックのページを作成する' do
    context '管理者がログインしている' do
      let(:admin) { create(:admin) }
      let(:web_book) { create(:web_book) }
      let(:author) { create(:author) }

      before do
        login_as(admin)
        create(:web_book_author, web_book: web_book, author: author)
      end

      it 'Webブックのページが作成される' do
        visit admins_web_book_path(web_book)
        click_link 'ページ追加'
        # バリデーションエラーをテスト
        expect do
          click_button '作成する'
          expect(page).to have_css('.alert.alert-warning')
        end.not_to change(Page, :count)
        fill_in I18n.t('activerecord.attributes.page.title'), with: 'page_title'
        fill_in I18n.t('activerecord.attributes.page.body'), with: '# body'
        expect do
          click_button '作成する'
          expect(page).to have_content(I18n.t('admins.web_books.pages.create.success'))
        end.to change(Page, :count).by(1)
        expect(page).to have_current_path admins_web_book_page_path(web_book, Page.last), ignore_query: true
        expect(page).to have_content('page_title')
        expect(page).to have_content('body')
      end

      it 'Webブックのページをプレビューできる' do
        visit admins_web_book_path(web_book)
        click_link 'ページ追加'
        fill_in I18n.t('activerecord.attributes.page.title'), with: 'page_title'
        fill_in I18n.t('activerecord.attributes.page.body'), with: '# body'
        expect do
          click_button 'プレビュー'
          expect(page).to have_content('page_title')
          expect(page).to have_content('body')
          expect(page).not_to have_field I18n.t('activerecord.attributes.page.title'), with: 'page_title'
          expect(page).not_to have_field I18n.t('activerecord.attributes.page.body'), with: '# body'
        end.to change(Page, :count).by(0)
        expect do
          click_button '戻る'
          expect(page).to have_field I18n.t('activerecord.attributes.page.title'), with: 'page_title'
          expect(page).to have_field I18n.t('activerecord.attributes.page.body'), with: '# body'
        end.to change(Page, :count).by(0)
      end
    end
  end

  describe 'Webブックのページ編集ページにアクセスする' do
    let(:web_book) { create(:web_book) }
    let(:author) { create(:author) }
    let(:web_book_page) { create(:page, web_book: web_book, title: 'page_title', body: 'page_body') }

    before { create(:web_book_author, web_book: web_book, author: author) }

    context '管理者がログインしている' do
      let(:admin) { create(:admin) }

      before { login_as(admin) }

      it 'Webブックのページ編集ページが表示される' do
        visit admins_web_book_page_path(web_book, web_book_page)
        click_link '編集'
        expect(page).to have_current_path edit_admins_web_book_page_path(web_book, web_book_page), ignore_query: true
        expect(page).to have_field I18n.t('activerecord.attributes.page.title'), with: 'page_title'
        expect(page).to have_field I18n.t('activerecord.attributes.page.body'), with: 'page_body'
      end
    end

    context '管理者がログインしていない' do
      it 'ログインページが表示される' do
        visit edit_admins_web_book_page_path(web_book, web_book_page)
        expect(page).to have_current_path new_admin_session_path, ignore_query: true
        expect(page).to have_content('Log in')
      end
    end
  end

  describe 'Webブックのページを編集する' do
    context '管理者がログインしている' do
      let(:admin) { create(:admin) }
      let(:web_book) { create(:web_book) }
      let(:author) { create(:author) }
      let(:web_book_page) { create(:page, title: 'old_title', body: '# old_body', web_book: web_book) }

      before do
        login_as(admin)
        create(:web_book_author, web_book: web_book, author: author)
      end

      it 'Webブックのページが編集される' do
        visit admins_web_book_page_path(web_book, web_book_page)
        expect(page).to have_content('old_title')
        click_link '編集'
        # バリデーションエラーをテスト
        fill_in I18n.t('activerecord.attributes.page.title'), with: '', fill_options: { clear: :backspace }
        expect do
          click_button '更新する'
          expect(page).to have_css('.alert.alert-warning')
          web_book_page.reload
        end.not_to change(web_book_page, :title)
        fill_in I18n.t('activerecord.attributes.page.title'), with: 'new_title', fill_options: { clear: :backspace }
        expect do
          click_button '更新する'
          expect(page).to have_content(I18n.t('admins.web_books.pages.update.success'))
          web_book_page.reload
        end.to change(web_book_page, :title).from('old_title').to('new_title')
        expect(page).to have_current_path admins_web_book_page_path(web_book, web_book_page), ignore_query: true
        expect(page).to have_content('new_title')
      end

      it 'Webブックのページをプレビューできる' do
        visit admins_web_book_page_path(web_book, web_book_page)
        click_link '編集'
        expect(page).to have_field I18n.t('activerecord.attributes.page.title'), with: 'old_title'
        expect(page).to have_field I18n.t('activerecord.attributes.page.body'), with: '# old_body'
        fill_in I18n.t('activerecord.attributes.page.title'), with: 'new_title', fill_options: { clear: :backspace }
        fill_in I18n.t('activerecord.attributes.page.body'), with: '# new_body', fill_options: { clear: :backspace }
        expect do
          click_button 'プレビュー'
          expect(page).to have_content('new_title')
          expect(page).to have_content('new_body')
          expect(page).not_to have_field I18n.t('activerecord.attributes.page.title'), with: 'new_title'
          expect(page).not_to have_field I18n.t('activerecord.attributes.page.body'), with: '# new_body'
          web_book_page.reload
        end.to not_change(web_book_page, :title).and not_change(web_book_page, :body)
        expect do
          click_button '戻る'
          expect(page).to have_field I18n.t('activerecord.attributes.page.title'), with: 'new_title'
          expect(page).to have_field I18n.t('activerecord.attributes.page.body'), with: '# new_body'
          expect(page).not_to have_field I18n.t('activerecord.attributes.page.title'), with: 'old_title'
          expect(page).not_to have_field I18n.t('activerecord.attributes.page.body'), with: '# old_body'
          web_book_page.reload
        end.to not_change(web_book_page, :title).and not_change(web_book_page, :body)
      end
    end
  end

  describe 'Webブックのページを削除する' do
    let(:admin) { create(:admin) }
    let(:web_book) { create(:web_book, title: 'web_book_title', released: true) }
    let(:author) { create(:author) }

    before do
      login_as(admin)
      create(:web_book_author, web_book: web_book, author: author)
      create(:page, title: 'page_title1', body: 'page_body1', web_book: web_book)
      create(:page, title: 'page_title2', web_book: web_book)
      # before_save回避のためにFactoryBotで作られたページを削除
      Page.where(title: 'delete_title').destroy_all
    end

    it 'Webブックのページが削除される' do
      visit admins_web_book_path(web_book)
      expect(page).to have_content('page_title1')
      expect(page).to have_content('page_title2')
      click_link 'page_title1'
      expect(page).to have_content('page_body1')
      click_button '削除'
      expect do
        expect(page.accept_confirm).to eq '本当に削除しますか?'
        expect(page).to have_content(I18n.t('admins.web_books.pages.destroy.success'))
      end.to change(Page, :count).by(-1)
      expect(page).to have_current_path admins_web_book_path(web_book), ignore_query: true
      expect(page).not_to have_content('page_title1')
      expect(page).to have_content('page_title2')
      expect(page).to have_content('web_book_title')
    end
  end
end
