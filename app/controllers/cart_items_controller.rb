class CartItemsController < ApplicationController
  before_action :set_web_book, only: %i[create destroy]
  PER_PAGE = 10

  def index
    total_web_books = WebBook.preload(:authors).
                      with_attached_cover_image.
                      released.
                      where(id: web_book_ids_in_cookie).
                      sort_by { |web_book| web_book_ids_in_cookie.index(web_book.id) }
    @total_price = total_web_books.sum(&:price_including_tax)
    @web_books = Kaminari.paginate_array(total_web_books).page(params[:page]).per(PER_PAGE)
  end

  def create
    if add_to_cart(@web_book)
      redirect_to @web_book, flash: { success: t('.success') }
    else
      redirect_to @web_book, flash: { danger: t('.danger') }
    end
  end

  def destroy
    remove_from_cart(@web_book)
    redirect_to ({ action: :index }), flash: { success: t('.success') }
  end

  private

  def set_web_book
    @web_book = WebBook.released.find(params[:id])
  end

  def add_to_cart(web_book)
    web_book_ids_in_cart = web_book_ids_in_cookie
    # 高速化のためSetクラスに変換
    if Set.new(web_book_ids_in_cart).exclude?(web_book.id)
      web_book_ids_in_cart.push(web_book.id)
      store_web_book_ids_in_cookie(web_book_ids_in_cart)
      true
    else
      false
    end
  end

  def remove_from_cart(web_book)
    web_book_ids_in_cart = web_book_ids_in_cookie
    web_book_ids_in_cart.delete(web_book.id)
    store_web_book_ids_in_cookie(web_book_ids_in_cart)
  end
end
