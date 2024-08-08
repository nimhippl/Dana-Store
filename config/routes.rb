Rails.application.routes.draw do
  get 'newsletters/index'
  get 'newsletters/create'
  get 'web_app', to: 'web_app#index'
  get 'web_app/products/:category_id', to: 'web_app#products', as: 'web_app_products'
  post 'create_order', to: 'orders#create_order'
  devise_for :users, controllers: {
    sessions: 'users/sessions'
  }

  root to: 'reports#index'

  devise_scope :user do
    delete 'logout', to: 'devise/sessions#destroy', as: :logout
  end

  resources :reports, only: [:index] do
    collection do
      get :user_reports
    end
    member do
      get :user_report
      get :edit_payment
      post :update_payments
      post :pay_all_orders
    end
  end

  resources :users, only: [:index, :show, :destroy] do
    collection do
      get :pending_requests
      get :archived, to: 'users#archived', as: 'archived_users'
      post :request_connection
      patch :activate
      delete :destroy_all
      patch :activate_all
    end
    member do
      get :archived_show
      get :restore, to: 'users#restore'
      delete :really_destroy
    end
  end

  resources :products do
    collection do
      get :archived, to: 'products#archived', as: 'archived_products'
    end
    member do
      get :archived_show, to: 'products#archived_show', as: 'archived_show'
      get :restore, to: 'products#restore'
      delete :really_destroy, to: 'products#really_destroy'
    end
  end

  resources :categories, only: [:index, :new, :create, :destroy]

  resources :orders, only: [:index, :create, :new, :destroy] do
    collection do
      get 'archived', to: 'orders#archived'
      post :create_order
      get :list, to: 'orders#list_orders'
      delete :delete_last, to: 'orders#delete_last_order'
    end
    member do
      delete :really_destroy
    end
  end


  resources :newsletters, only: [:index, :create]


  telegram_webhook TelegramWebhookController
end
