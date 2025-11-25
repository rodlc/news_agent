# config/routes.rb
Rails.application.routes.draw do
  devise_for :users
  
  root to: "dailies#index"
  
  # Routes pour les chats
  resources :chats, only: [:show, :create] do
    resources :messages, only: [:create]
  end
  
  # Reveal health status on /up
  get "up" => "rails/health#show", as: :rails_health_check
end
