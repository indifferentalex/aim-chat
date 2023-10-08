Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  root "chats#index"
  get "/chat", to: "chats#index"
  get "/chats/:id", to: "chats#show"
  post "/chat/:chat_id", to: "chats#process_message"

end
