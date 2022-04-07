class Admins::WebBooksController < Admins::ApplicationController
  before_action :set_web_book, only: %i[show edit update destroy]
  PER_PAGE = 30

  def index
    @web_books = WebBook.preload(:authors).
                 with_attached_cover_image.
                 recently_released.
                 recently_saved.
                 page(params[:page]).per(PER_PAGE)
  end

  def show
    @pages = @web_book.pages.rank(:page_order)
  end

  def new
    @web_book_form = WebBookForm.new
  end

  def create
    @web_book_form = WebBookForm.new(web_book_form_params)
    if @web_book_form.save
      redirect_to admins_web_book_path(@web_book_form.web_book), flash: { success: t('.success') }
    else
      render :new
    end
  end

  def edit
    @web_book_form = WebBookForm.new(web_book: @web_book)
  end

  def update
    @web_book_form = WebBookForm.new(web_book_form_params, web_book: @web_book)
    if @web_book_form.save
      redirect_to admins_web_book_path(@web_book), flash: { success: t('.success') }
    else
      render :edit
    end
  end

  def destroy
    @web_book.destroy!
    redirect_to admins_root_path, flash: { success: t('.success') }
  end

  private

  def web_book_form_params
    params.require(:web_book_form).permit(:title, :release_date, :price, :description, :released, :cover_image, authors_attributes: %i[name])
  end

  def set_web_book
    @web_book = WebBook.find(params[:id])
  end
end
