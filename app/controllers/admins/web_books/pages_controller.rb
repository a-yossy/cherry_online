class Admins::WebBooks::PagesController < Admins::WebBooks::ApplicationController
  before_action :set_page, only: %i[show edit update destroy sort]
  before_action :set_preview_page, only: %i[create update]

  def show
  end

  def new
    @page = @web_book.pages.build
  end

  def create
    @page = @web_book.pages.build(page_params)
    render :preview and return if params[:preview]
    render :new and return if params[:back]

    if @page.save
      redirect_to admins_web_book_page_path(@web_book, @page), flash: { success: t('.success') }
    else
      render :new
    end
  end

  def edit
    @preview_page_title = @page.title
    @preview_page_body = @page.body
  end

  def update
    render :preview and return if params[:preview]
    render :edit and return if params[:back]

    if @page.update(page_params)
      redirect_to admins_web_book_page_path(@page.web_book, @page), flash: { success: t('.success') }
    else
      render :edit
    end
  end

  def destroy
    @page.destroy!
    redirect_to admins_web_book_path(@web_book), flash: { success: t('.success') }
  end

  def sort
    @page.update(page_order_params)
    render body: nil
  end

  def preview
  end

  private

  def set_page
    @page = @web_book.pages.find(params[:id])
  end

  def set_preview_page
    @preview_page_title = params[:page][:title]
    @preview_page_body = params[:page][:body]
  end

  def page_params
    params.require(:page).permit(:title, :body, :page_order_position)
  end

  def page_order_params
    params.require(:page).permit(:page_order_position)
  end
end
