Xems::Application.routes.draw do
  root 'welcome#index'
  scope :api do
    resources :sessions, only: [:show, :create, :destroy]
    resources :users do
      collection do
        get :users
      end
    end
    resources :customers do
      member do
        get :contacts
      end
    end
    resources :suppliers do
      member do
        get :contacts
      end
    end
    resources :tasks
    resources :categories
    resources :projects do
      member do
        get :customers
        get :users
      end
      resources :project_tasks
      resources :project_files
    end
    resources :project_customers, only: [:create, :destroy]
    resources :project_users, only: [:create, :destroy]
    resources :plancategories
    resources :plantypes
  end
end
