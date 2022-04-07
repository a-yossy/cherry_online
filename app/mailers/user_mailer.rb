class UserMailer < ApplicationMailer
  def order_completion
    @name = params[:name]
    @total_amount = params[:total_amount]
    @order_date_and_time = params[:order_date_and_time]
    @web_books = params[:web_books]
    mail(to: params[:email], subject: '【Cherry Online】注文完了のお知らせ')
  end

  def purchase_completion
    @name = params[:name]
    @total_amount = params[:total_amount]
    @purchase_date_and_time = params[:purchase_date_and_time]
    @web_books = params[:web_books]
    mail(to: params[:email], subject: '【Cherry Online】購入完了のお知らせ')
  end
end
