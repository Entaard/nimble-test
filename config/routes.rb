Rails.application.routes.draw do
  root 'home#index'

  get 'home/index'
  post 'home/upload'

  resources :users, only: [:new, :create]

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  get 'welcome', to: 'sessions#welcome'

  get 'report', to: 'report#index'
end
