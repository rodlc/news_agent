# config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  resources :chats, only: [:show, :create] do
    resources :messages, only: [:create]
    resources :dailies, only: [:new, :create]  # Nested pour création depuis chat
  end

  # Routes standalone pour dailies (CRUD après création)
  resources :dailies, only: [:show, :edit, :update, :destroy]

  get "up" => "rails/health#show", as: :rails_health_check
end
