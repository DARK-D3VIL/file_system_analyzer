Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root "session#new"

  get "login", to: "session#new"
  post "login", to: "session#create"
  delete "logout", to: "session#destroy"

  get '/browse', to: 'browse#index', as: :browse
  post '/browse/select', to: 'browse#select', as: :select_folder

  get "dashboard", to: "dashboard#index"
  get "files", to: "files#index"
  delete "files/delete/:id", to: "files#destroy", as: :delete_file

  get "overview", to: "overview#index"
  get "overview/duplicates", to: "overview#duplicates"
  get "overview/anomalous", to: "overview#anomalous"
  get "overview/archivable", to: "overview#archivable"
end
