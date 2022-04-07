require 'rails_helper'

RSpec.describe 'WebBook', type: :system do
  describe 'TOPページにアクセスする' do
    context '管理者がログインしている' do
      let(:admin) { create(:admin) }

      let(:released_web_book) { create(:web_book, title: 'released_title', released: true) }
      let(:not_released_web_book) { create(:web_book, title: 'not_released_title', released: true) }
      let(:author1) { create(:author, name: 'author1') }
      let(:author2) { create(:author, name: 'author2') }

      before do
        login_as(admin)

        create(:web_book_author, web_book: released_web_book, author: author1)
        create(:web_book_author, web_book: released_web_book, author: author2)
        create(:web_book_author, web_book: not_released_web_book, author: author1)
      end

      it 'TOPページが表示される' do
        visit admins_root_path
        expect(page).to have_content('管理者ページ')
        expect(page).to have_content('released_title')
        expect(page).to have_content('author1')
        expect(page).to have_content('author2')
        expect(page).to have_content('not_released_title')
        expect(page).not_to have_content('未公開')
        not_released_web_book.update(released: false)
        visit admins_web_books_path
        expect(page).to have_content('not_released_title')
        expect(page).to have_content('未公開')
      end
    end

    context '管理者がログインしていない' do
      it 'ログインページが表示される' do
        visit admins_root_path
        expect(page).to have_current_path new_admin_session_path, ignore_query: true
        expect(page).to have_content('Log in')
        expect(page).not_to have_content('管理者ページ')
      end
    end
  end

  describe 'Webブック詳細ページにアクセスする' do
    let(:web_book) { create(:web_book, title: 'title', description: '# description', released: true) }
    let(:author1) { create(:author, name: 'author1') }
    let(:author2) { create(:author, name: 'author2') }

    before do
      create(:web_book_author, web_book: web_book, author: author1)
      create(:web_book_author, web_book: web_book, author: author2)
      create(:page, title: 'page_title', web_book: web_book)
      # before_save回避のためにFactoryBotで作られたページを削除
      Page.where(title: 'delete_title').destroy_all
    end

    context '管理者がログインしている' do
      let(:admin) { create(:admin) }

      before { login_as(admin) }

      it 'Webブック詳細ページが表示される' do
        visit admins_root_path
        click_link 'title'
        expect(page).to have_current_path admins_web_book_path(web_book), ignore_query: true
        expect(page).to have_content('title')
        expect(page).to have_content('author1')
        expect(page).to have_content('author2')
        expect(page).not_to have_content('カートに入れる')
        expect(page).to have_content('description')
        expect(page).to have_content('1ページ')
        expect(page).to have_content('page_title')
      end
    end

    context '管理者がログインしていない' do
      it 'ログインページが表示される' do
        visit admins_web_book_path(web_book)
        expect(page).to have_current_path new_admin_session_path, ignore_query: true
        expect(page).to have_content('Log in')
      end
    end
  end

  describe 'WebBook作成ページにアクセスする' do
    context '管理者がログインしている' do
      let(:admin) { create(:admin) }

      before { login_as(admin) }

      it 'WebBook作成ページが表示される' do
        visit admins_root_path
        click_link 'Webブック作成'
        expect(page).to have_current_path new_admins_web_book_path, ignore_query: true
        expect(page).to have_selector('.form-control')
        expect(page).to have_field I18n.t('activemodel.attributes.web_book_form.released'), disabled: true
      end
    end

    context '管理者がログインしていない' do
      it 'ログインページが表示される' do
        visit new_admins_web_book_path
        expect(page).to have_current_path new_admin_session_path, ignore_query: true
        expect(page).to have_content('Log in')
        expect(page).not_to have_selector('.form-control')
        expect(page).not_to have_field(I18n.t('activemodel.attributes.web_book_form.released'))
      end
    end
  end

  describe 'WebBookを作成する' do
    context '管理者がログインしている' do
      let(:admin) { create(:admin) }

      before { login_as(admin) }

      it 'WebBookが作成される' do
        visit admins_root_path
        click_link 'Webブック作成'
        # バリデーションエラーをテスト
        expect do
          click_button '作成する'
          expect(page).to have_css('.alert.alert-warning')
        end.to change(WebBook, :count).by(0).and change(Author, :count).by(0).and change(WebBookAuthor, :count).by(0)
        fill_in I18n.t('activemodel.attributes.web_book_form.title'), with: 'title'
        fill_in I18n.t('activemodel.attributes.web_book_form.release_date'), with: '002021-01-01'
        fill_in I18n.t('activemodel.attributes.web_book_form.price'), with: 1000
        fill_in I18n.t('activemodel.attributes.web_book_form.description'), with: '# description'
        expect(page).to have_field I18n.t('activemodel.attributes.web_book_form.released'), disabled: true
        attach_file I18n.t('activemodel.attributes.web_book_form.cover_image'), Rails.root.join('spec/support/no_image.jpg')
        fill_in I18n.t('activerecord.attributes.author.name'), with: 'author1', id: 'web_book_form_authors_attributes_0_name'
        fill_in I18n.t('activerecord.attributes.author.name'), with: 'author2', id: 'web_book_form_authors_attributes_1_name'
        expect do
          click_button '作成する'
          expect(page).to have_content(I18n.t('admins.web_books.create.success'))
        end.to change(WebBook, :count).by(1).and change(Author, :count).by(2)
        expect(page).to have_current_path admins_web_book_path(WebBook.last), ignore_query: true
        expect(page).to have_content('title')
        expect(page).to have_content('author1')
        expect(page).to have_content('author2')
        expect(page).to have_content('2021/01/01発売')
        expect(page).to have_content('1,100円')
        expect(page).to have_selector('img')
        expect(page).to have_content('description')
      end
    end
  end

  describe 'Webブック編集ページにアクセスする' do
    let(:web_book) { create(:web_book, title: 'title', released: true) }
    let(:author1) { create(:author, name: 'author1') }
    let(:author2) { create(:author, name: 'author2') }

    before do
      create(:web_book_author, web_book: web_book, author: author1)
      create(:web_book_author, web_book: web_book, author: author2)
    end

    context '管理者がログインしている' do
      let(:admin) { create(:admin) }

      before { login_as(admin) }

      it 'Webブック編集ページが表示される' do
        visit admins_root_path
        click_link 'title'
        click_link '編集'
        expect(page).to have_current_path edit_admins_web_book_path(web_book), ignore_query: true
        expect(page).to have_field I18n.t('activemodel.attributes.web_book_form.title'), with: 'title'
        expect(page).to have_field I18n.t('activemodel.attributes.web_book_form.released')
        expect(page).not_to have_field I18n.t('activemodel.attributes.web_book_form.released'), disabled: true
        web_book.update(released: false)
        web_book.pages.destroy_all
        visit edit_admins_web_book_path(web_book)
        expect(page).not_to have_field I18n.t('activemodel.attributes.web_book_form.released')
        expect(page).to have_field I18n.t('activemodel.attributes.web_book_form.released'), disabled: true
      end
    end

    context '管理者がログインしていない' do
      it 'ログインページが表示される' do
        visit admins_web_book_path(web_book)
        expect(page).to have_current_path new_admin_session_path, ignore_query: true
        expect(page).to have_content('Log in')
      end
    end
  end

  describe 'Webブックを編集する' do
    let(:web_book) { create(:web_book, title: 'old_title') }
    let(:author1) { create(:author, name: 'old_author1') }
    let(:author2) { create(:author, name: 'old_author2') }

    before do
      create(:web_book_author, web_book: web_book, author: author1)
      create(:web_book_author, web_book: web_book, author: author2)
    end

    context '管理者がログインしている' do
      let(:admin) { create(:admin) }

      before { login_as(admin) }

      it 'Webブックが編集される' do
        visit admins_root_path
        click_link 'old_title'
        expect(page).to have_content('old_title')
        expect(page).to have_content('old_author1')
        expect(page).to have_content('old_author2')
        click_link '編集'
        # バリデーションエラーをテスト
        fill_in I18n.t('activemodel.attributes.web_book_form.title'), with: '', fill_options: { clear: :backspace }
        expect do
          click_button '更新する'
          expect(page).to have_css('.alert.alert-warning')
          web_book.reload
        end.not_to change(web_book, :title)
        fill_in I18n.t('activemodel.attributes.web_book_form.title'), with: 'new_title', fill_options: { clear: :backspace }
        fill_in I18n.t('activerecord.attributes.author.name'), with: 'new_author1', id: 'web_book_form_authors_attributes_0_name',
                                                               fill_options: { clear: :backspace }
        fill_in I18n.t('activerecord.attributes.author.name'), with: 'new_author2', id: 'web_book_form_authors_attributes_1_name',
                                                               fill_options: { clear: :backspace }
        expect do
          click_button '更新する'
          expect(page).to have_content(I18n.t('admins.web_books.update.success'))
          web_book.reload
        end.to change(Author, :count).by(2).and change(web_book, :title).from('old_title').to('new_title')
        expect(page).to have_current_path admins_web_book_path(web_book), ignore_query: true
        expect(page).to have_content('new_title')
        expect(page).to have_content('new_author1')
        expect(page).to have_content('new_author2')
        expect(page).not_to have_content('old_author1')
        expect(page).not_to have_content('old_author2')
      end
    end
  end

  describe 'Webブックを削除する' do
    let(:admin) { create(:admin) }
    let(:web_book) { create(:web_book, title: 'title', released: false) }

    before do
      create(:web_book_author, web_book: web_book)
      create(:page, web_book: web_book)
      # before_save回避のためにFactoryBotで作られたページを削除
      Page.where(title: 'delete_title').destroy_all
      login_as(admin)
    end

    it 'Webブックが削除される' do
      visit admins_root_path
      click_link 'title'
      expect(page).to have_current_path admins_web_book_path(web_book), ignore_query: true
      expect(page).to have_link('この本を読む')
      click_button '削除'
      expect do
        expect(page.accept_confirm).to eq '本当に削除しますか?'
        expect(page).to have_content(I18n.t('admins.web_books.destroy.success'))
      end.
        to change(WebBook, :count).by(-1).
        and change(Page, :count).by(-1).
        and change(WebBookAuthor, :count).by(-1).
        and change(Author, :count).by(0).
        and change(PurchaseRecord, :count).by(0).
        and change(User, :count).by(0)
      expect(page).to have_current_path admins_root_path, ignore_query: true
      expect(page).to have_link('Webブック作成')
      expect(page).not_to have_content('title')
    end
  end

  describe 'Webブックのページを並び替える' do
    context '管理者がログインしている' do
      let(:admin) { create(:admin) }
      let(:web_book) { create(:web_book) }
      let(:author) { create(:author) }
      let!(:first_page) { create(:page, title: 'first_page', page_order: 1, web_book: web_book) }
      let!(:second_page) { create(:page, title: 'second_page', page_order: 2, web_book: web_book) }
      let!(:third_page) { create(:page, title: 'third_page', page_order: 3, web_book: web_book) }

      before do
        login_as(admin)
        create(:web_book_author, web_book: web_book, author: author)
        # before_save回避のためにFactoryBotで作られたページを削除
        Page.where(title: 'delete_title').destroy_all
      end

      it 'Webブックのページが並び替えられる' do
        visit admins_web_book_path(web_book)
        expect(all('#pages li')[0]).to have_content('first_page')
        expect(all('#pages li')[1]).to have_content('second_page')
        expect(all('#pages li')[2]).to have_content('third_page')
        source = all('#pages li')[0]
        target = all('#pages li')[2]
        expect { source.drag_to(target) }.
          to change { Page.rank(:page_order) }.
          from([first_page, second_page, third_page]).
          to([second_page, third_page, first_page])
        visit admins_web_book_path(web_book)
        expect(all('#pages li')[0]).to have_content('second_page')
        expect(all('#pages li')[1]).to have_content('third_page')
        expect(all('#pages li')[2]).to have_content('first_page')
      end
    end
  end
end
