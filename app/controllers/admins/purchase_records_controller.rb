class Admins::PurchaseRecordsController < Admins::ApplicationController
  PER_PAGE = 20

  def index
    @purchase_records = PurchaseRecord.preload(:web_book, :user, :order_detail).recently_ordered.page(params[:page]).per(PER_PAGE)
  end
end
