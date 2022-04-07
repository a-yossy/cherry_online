class Admins::OrderDetailsController < Admins::ApplicationController
  before_action :set_order_detail, only: %i[show update]
  PER_PAGE = 20

  def index
    @q = OrderDetail.ransack(search_params)
    @order_details = @q.result.eager_load(:user).recently_ordered.page(params[:page]).per(PER_PAGE)
  end

  def show
  end

  def update
    if complete_payment(@order_detail)
      redirect_to ({ action: :index }), flash: { success: t('.success') }
    else
      redirect_to ({ action: :index }), flash: { danger: t('.danger') }
    end
  end

  private

  def search_params
    params.fetch(:q, {}).permit(:paid_eq)
  end

  def set_order_detail
    @order_detail = OrderDetail.find(params[:id])
  end

  def complete_payment(order_detail)
    if order_detail.paid?
      false
    elsif order_detail.update(paid: true)
      ordered_web_book_ids = order_detail.purchase_records.formerly_ordered.pluck(:web_book_id)
      # 削除済みのユーザーで発生するエラー防止のため記述
      if order_detail.user
        UserMailer.with(
          name: order_detail.user.name,
          email: order_detail.user.email,
          total_amount: order_detail.total_amount,
          purchase_date_and_time: Time.zone.now,
          web_books: WebBook.where(id: ordered_web_book_ids).sort_by { |web_book| ordered_web_book_ids.index(web_book.id) }
        ).purchase_completion.deliver_now
      end
      true
      # rubocop:disable Lint/DuplicateBranch
    else
      false
      # rubocop:enable Lint/DuplicateBranch
    end
  end
end
