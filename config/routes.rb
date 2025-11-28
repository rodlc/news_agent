# config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  # Routes pour les dailies avec chats nested
  resources :dailies, only: [:index, :create, :edit, :update, :destroy] do
    resources :chats, only: [:create]
  end

  # Routes pour les chats (pour show et messages)
  resources :chats, only: [:show] do
    resources :messages, only: [:create]
    member do
      post :generate_summary
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check
end
