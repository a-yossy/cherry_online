class ApplicationController < ActionController::Base
  include CookieHandleable
  before_action :store_empty_array_in_cookie
  helper_method :web_book_ids_in_cookie
  rescue_from ActiveRecord::RecordNotFound, with: :render404

  def render404
    render 'errors/error404', status: :not_found
  end
end
