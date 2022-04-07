class Users::WebBooks::ApplicationController < Users::ApplicationController
  before_action :set_web_book

  def set_web_book
    @web_book = current_user.recently_ordered_paid_web_books.find(params[:web_book_id])
  end
end
