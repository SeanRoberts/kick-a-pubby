Tf2lcs::Application.routes.draw do
  resources :friends

  resources :players do
    post :kick, :on => :collection
  end
  
  match "/auth/:provider/callback" => "sessions#create"
  match "/signout" => "sessions#destroy", :as => :signout
  
  root :to => "players#index"
end
