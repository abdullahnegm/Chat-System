Rails.application.routes.draw do
  get '/applications/:token/chats', to: 'chats#index'
  get '/applications/:token/chats/:number', to: 'chats#show'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
