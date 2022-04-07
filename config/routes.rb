Rails.application.routes.draw do
  root 'web_books#index'
  namespace :admins do
    root 'web_books#index'
    resources :web_books do
      scope module: :web_books do
        resources :pages, only: %i[show new create edit update destroy] do
          put :sort, on: :member
        end
        resource :preview, only: %i[show] do
          resources :pages, only: %i[show], module: :preview
        end
      end
    end
    resources :order_details, only: %i[index show update]
    resources :purchase_records, only: %i[index]
  end
  namespace :users do
    resources :orders, only: %i[create]
    resources :web_books, only: %i[index] do
      scope module: :web_books do
        resource :reading, only: %i[show] do
          resources :pages, only: %i[show], module: :reading
        end
      end
    end
  end
  resources :web_books, only: %i[index show]
  resources :cart_items, only: %i[index create destroy]
  devise_for :admins, controllers: {
    sessions: 'admins/sessions',
  }
  devise_for :users, controllers: {
    sessions:      'users/sessions',
    registrations: 'users/registrations',
  }
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
end
