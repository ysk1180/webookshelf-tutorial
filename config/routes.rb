Rails.application.routes.draw do
  root to: 'posts#new'
  get 'search', to: 'posts#search'
  post 'make', to: 'posts#make'
end
