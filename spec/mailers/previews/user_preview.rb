# Preview all emails at http://localhost:3000/rails/mailers/user
class UserPreview < ActionMailer::Preview
  def order_completion
    web_books = [WebBook.first, WebBook.second]
    UserMailer.with(
      name: User.first.name,
      email: User.first.email,
      web_books: web_books,
      total_amount: web_books.sum(&:price_including_tax),
      order_date_and_time: Time.zone.now
    ).order_completion
  end

  def purchase_completion
    web_books = [WebBook.first, WebBook.second]
    UserMailer.with(
      name: User.first.name,
      email: User.first.email,
      web_books: web_books,
      total_amount: web_books.sum(&:price_including_tax),
      purchase_date_and_time: Time.zone.now
    ).purchase_completion
  end
end
