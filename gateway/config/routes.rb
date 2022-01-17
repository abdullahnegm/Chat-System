Rails.application.routes.draw do
  resources :applications, param: :token do 
    resources :chats, param: :number do 
      resources :messages, param: :message_number do
        post '/search', to: 'messages#search'
      end
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
