module CartHelper
  def already_added_to_cart?(web_book)
    # 高速化のためSetクラスに変換
    web_books_in_cart = Set.new(JSON.parse(cookies[Constants::WEB_BOOKS_IN_CART_COOKIE_NAME]))
    web_books_in_cart.include?(web_book.id)
  end

  def already_purchased?(web_book)
    # 高速化のためSetクラスに変換
    web_books_in_cart = Set.new(current_user.web_books.pluck(:id))
    web_books_in_cart.include?(web_book.id)
  end
end
