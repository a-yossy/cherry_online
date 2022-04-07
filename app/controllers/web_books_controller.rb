class WebBooksController < ApplicationController
  before_action :set_web_book, only: %i[show]
  PER_PAGE = 30

  def index
    @web_books = WebBook.preload(:authors).
                 with_attached_cover_image.
                 released.
                 recently_released.
                 recently_saved.
                 page(params[:page]).per(PER_PAGE)
  end

  def show
    @pages = @web_book.pages.rank(:page_order)
  end

  private

  def set_web_book
    @web_book = WebBook.released.find(params[:id])
  end
end
