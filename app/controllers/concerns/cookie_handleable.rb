module CookieHandleable
  def web_book_ids_in_cookie
    JSON.parse(cookies[Constants::WEB_BOOKS_IN_CART_COOKIE_NAME])
  end

  def store_web_book_ids_in_cookie(web_book_ids)
    cookies[Constants::WEB_BOOKS_IN_CART_COOKIE_NAME] = { value: JSON.generate(web_book_ids), expires: 2.days.from_now }
  end

  def delete_web_book_ids_cookie
    cookies.delete Constants::WEB_BOOKS_IN_CART_COOKIE_NAME
  end

  private

  # カートが空の際に起こるエラーを防ぐため記述
  def store_empty_array_in_cookie
    cookies[Constants::WEB_BOOKS_IN_CART_COOKIE_NAME] ||= { value: JSON.generate([]), expires: 2.days.from_now }
  end
end
