class Users::WebBooksController < Users::ApplicationController
  PER_PAGE = 30

  def index
    @web_books = current_user.recently_ordered_paid_web_books.
                 includes(:authors).
                 with_attached_cover_image.
                 page(params[:page]).per(PER_PAGE)
  end
end
