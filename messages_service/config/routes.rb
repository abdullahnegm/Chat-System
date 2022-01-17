Rails.application.routes.draw do
  get '/applications/:token/chats/:chat_number/messages', to: 'messages#index'
  get '/applications/:token/chats/:chat_number/messages/:number', to: 'messages#show'

  post '/applications/:token/chats/:chat_number/messages/search', to: 'messages#search'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
