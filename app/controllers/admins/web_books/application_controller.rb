class Admins::WebBooks::ApplicationController < Admins::ApplicationController
  before_action :set_web_book

  def set_web_book
    @web_book = WebBook.find(params[:web_book_id])
  end
end
