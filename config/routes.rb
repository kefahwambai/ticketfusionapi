Rails.application.routes.draw do
  resources :orders, only: [:create]
  resources :mpesas
  ActiveAdmin.routes(self)
  resources :sales
  resources :tickets do
    member do
      get 'download', to: 'tickets#download_ticket'
      get 'validate', to: 'tickets#validate_ticket'
    end
  end
  resources :events do
    resources :tickets, only: [:index]
  end
  resources :users do
    collection do
      get 'current', to: 'users#current'
    end
  end
  
  post '/signup', to: 'users#create'
  post '/auth/refresh', to: 'authentication#refresh'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy'
  post 'stkpush', to: 'mpesas#stkpush'
  post 'callback', to: 'mpesa#callback'
  post 'stkquery', to: 'mpesas#stkquery'
end
