# For details on the DSL available within this file,
# see http://guides.rubyonrails.org/routing.html

Rails.application.routes.draw do
  jsonapi_resources :friends
  jsonapi_resources :articles
  jsonapi_resources :loans
end
