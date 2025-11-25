# config/routes.rb
Rails.application.routes.draw do
  devise_for :users

  root to: "pages#home"

  # Routes pour les chats (on enlève le nested dans dailies)
  resources :chats, only: [:show, :create] do
    resources :messages, only: [:create]
  end

  # Reveal health status on /up
  get "up" => "rails/health#show", as: :rails_health_check
end
