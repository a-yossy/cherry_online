class Users::WebBooks::Reading::PagesController < Users::WebBooks::ApplicationController
  before_action :set_page, only: %i[show]

  def show
  end

  private

  def set_page
    @page = @web_book.pages.find(params[:id])
  end
end
