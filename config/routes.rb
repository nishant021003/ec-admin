# frozen_string_literal: true

Rails.application.routes.draw do
  get "locale/:locale", to: "locales#switch", as: :switch_locale

  namespace :admin do
    root "dashboard#index"

    get    "login",  to: "sessions#new"
    post   "login",  to: "sessions#create"
    delete "logout", to: "sessions#destroy"

    resources :orders, only: %i[index show update] do
      get :export, on: :collection
    end
    resources :customers
    resources :categories
    resources :users, except: %i[show]
    resources :coupons
    resources :gift_cards
    resources :products do
      get :export, on: :collection
      post :import, on: :collection
      post :bulk_action, on: :collection
    end

    get "cart", to: "cart#index", as: :cart
    match "cart/add/:product_id", to: "cart#add", via: %i[get post], as: :cart_add
    patch "cart/update/:product_id", to: "cart#update", as: :cart_update
    delete "cart/remove/:product_id", to: "cart#remove", as: :cart_remove

    get "checkout", to: "checkout#index", as: :checkout
    post "checkout", to: "checkout#create"
  end

  get    "login",  to: "sessions#new",     as: :customer_login
  post   "login",  to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: :customer_logout

  root "admin/dashboard#index"
end
