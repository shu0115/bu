Bu::Application.routes.draw do

  resources :groups do
    get :description, on: :member

    resource :posts, only: [:create] do
      get ":renge" => "posts#index", as: "index"
    end

    resource :members, only: [] do #ユーザーが入部する
      put :leave
      put :join
      put :request_to_join
      put :delete_request
    end

    resources :memberships, only: [:index, :destroy] do #管理者が制限付きのグループへの参加を許可する
      member do
        put :confirm
        put :reject
      end
    end

    resources :roles, only: [:index, :show, :update, :destroy] #管理者がユーザーのロールを設定する

    resources :events, only: [:show, :new, :create, :edit, :update, :destroy] do
      member do
        put :cancel
        put :be_active
      end

      resource :attendees, only: [] do
        put :delete
        put :attend
        put :absent
        put :maybe
      end

      resources :comments, only: [:show, :create, :destroy]
    end
  end

  match '/auth/:provider/callback', :to => 'sessions#callback'
  match '/logout' => 'sessions#destroy', :as => :logout

  resource :my, controller: 'my', only: [:show, :edit, :update]
  resources :users, only: [:new, :show]

  get "about" => "welcome#about"
  root :to => 'welcome#index'
end
