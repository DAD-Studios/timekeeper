Rails.application.routes.draw do
  root "time_entries#new"

  resources :time_entries do
    member do
      patch :stop
    end
  end

  resources :projects

  resource :profile, only: [:edit, :update]
  resources :clients
  resources :invoices do
    member do
      get :download_pdf
      patch :mark_paid
    end
    resources :payments, only: [:create, :destroy], controller: 'invoice_payments'
  end

  resources :reports, only: [:index] do
    collection do
      get :daily
      get :weekly
      get :monthly
    end
  end

  namespace :api do
    resources :projects, only: [:index]
    get 'tasks', to: 'time_entries#tasks'

    namespace :v1 do
      resources :clients do
        resources :unbilled_time_entries, only: [:index]
      end
    end
  end

  # Custom error pages
  match '/404', to: 'errors#not_found', via: :all
  match '/422', to: 'errors#unprocessable_content', via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
end
