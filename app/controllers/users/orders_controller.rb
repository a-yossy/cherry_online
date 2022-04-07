class Users::OrdersController < Users::ApplicationController
  def create
    if order_web_books
      redirect_to root_path, flash: { success: t('.success') }
    else
      redirect_to root_path, flash: { danger: t('.danger') }
    end
  end

  private

  def order_web_books
    web_books_in_cart = WebBook.released.where(id: web_book_ids_in_cookie).sort_by { |web_book| web_book_ids_in_cookie.index(web_book.id) }
    if OrderDetail.order_web_books(web_books_in_cart, current_user)
      UserMailer.with(
        name: current_user.name,
        email: current_user.email,
        total_amount: web_books_in_cart.sum(&:price_including_tax),
        order_date_and_time: Time.zone.now,
        web_books: web_books_in_cart
      ).order_completion.deliver_now
      delete_web_book_ids_cookie
      true
    else
      false
    end
  end
end
