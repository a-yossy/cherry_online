class Admins::WebBooks::Preview::PagesController < Admins::WebBooks::ApplicationController
  before_action :set_page, only: %i[show]

  def show
  end

  private

  def set_page
    @page = @web_book.pages.find(params[:id])
  end
end
