Bu::Application.routes.draw do
  resources :groups do
    get :description, on: :member

    resource :posts, only: [:create] do
      match ":renge" => "posts#index"
    end

    resources :groups_member_requests, only: [:index] do #管理者の機能
      member do
        put :confirm
        put :reject
      end
    end

    resources :members, only: [:index, :show]
    resource :members, only: [] do #ユーザーの機能
      put :leave
      put :join
      put :request_to_join
      put :delete_request
    end

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

  resources :user_groups, only: [:update, :destroy] #roleの更新
  resource :my, controller: 'my', only: [:show, :edit, :update]
  resources :users, only: [:new, :show]

  get "about" => "welcome#about"
  root :to => 'welcome#index'
end
