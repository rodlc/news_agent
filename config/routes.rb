# config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  # Routes pour les chats (on enlève le nested dans dailies)
  resources :chats, only: [:show, :new, :create] do
    resources :messages, only: [:create]
    resources :dailies, only: [:new, :create]
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
