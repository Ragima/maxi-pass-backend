# frozen_string_literal: true

require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web, at: '/sidekiq'
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'
  mount_devise_token_auth_for 'User',
                              at: 'auth', skip: %i[invitations omniauth_callbacks],
                              controllers: {
                                confirmations: 'users/confirmations',
                                sessions: 'users/sessions',
                                token_validations: 'users/token_validations',
                                registrations: 'users/registrations',
                                passwords: 'users/passwords',
                                unlocks: 'users/unlocks'
                              }

  devise_for :users, path: 'auth', only: [:invitations],
                     controllers: { invitations: 'users/invitations' }

  devise_scope :user do
    get 'auth/invitation/resend_invitation/:user_id', to: 'users/invitations#resend_invitation'
    post 'auth/reset_otp', to: 'users/two_factor_auth#reset_otp'
    delete 'auth/invitation/:user_id', to: 'users/invitations#destroy'
  end

  get '/docs', to: 'apitome/docs#index'
  resources :vault_items, module: 'contents', only: %i[index show]

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :users, only: %i[index show create update destroy] do
        put 'change_role', to: 'users#change_role'
        put 'change_group_role/:group_id', to: 'users#change_group_role'
        put 'restore', to: 'users#restore'
        put 'toggle_block', to: 'users#toggle_block'
        post 'generate_report', to: 'users#generate_report'
      end
      post 'enable_two_factor/:team_name', to: 'teams#enable_two_factor'
      post 'disable_two_factor/:team_name', to: 'teams#disable_two_factor'
      get 'check_two_factor', to: 'teams#check_two_factor'
      get 'invitations', to: 'users#invitations'
      get 'users_reset_password', to: 'users#users_reset_password'
      put 'update_settings', to: 'users#update_settings'

      resources :groups, only: %i[index create show update destroy] do
        put 'update_parent/:parent_group_id', to: 'groups#update_parent'
        delete 'delete_parent/:parent_group_id', to: 'groups#delete_parent'
        post 'generate_report', to: 'groups#generate_report'
      end

      resources :vaults, only: %i[index show create update destroy] do
        get 'vault_items', to: 'vaults#vault_items'
        post 'generate_report', to: 'vaults#generate_report'
        resources :login_items, only: %i[show create update destroy] do
          post 'copy', to: 'login_items#copy'
          post 'move', to: 'login_items#move'
        end
        resources :server_items, only: %i[show create update destroy] do
          post 'copy', to: 'server_items#copy'
          post 'move', to: 'server_items#move'
          resources :documents, only: %i[show create update destroy]
        end
        resources :credit_card_items, only: %i[show create update destroy] do
          post 'copy', to: 'credit_card_items#copy'
          post 'move', to: 'credit_card_items#move'
        end
      end

      resources :subscriptions, only: %i[index]
      delete 'subscriptions/:subscription_action_id', to: 'subscriptions#destroy'
      post 'subscriptions/:subscription_action_id', to: 'subscriptions#create'
      post '/group_users/:group_id/:user_id', to: 'group_users#create'
      delete '/group_users/:group_id/:user_id', to: 'group_users#destroy'
      put '/group_users/:group_id/:user_id/change_role', to: 'group_users#change_role'
      post '/group_vaults/:group_id/:vault_id', to: 'group_vaults#create'
      delete '/group_vaults/:group_id/:vault_id', to: 'group_vaults#destroy'
      post '/user_vaults/:user_id/:vault_id', to: 'user_vaults#create'
      delete '/user_vaults/:user_id/:vault_id', to: 'user_vaults#destroy'
      put '/user_vaults/:user_id/:vault_id/change_role', to: 'user_vaults#change_role'

      get '/pages/home', to: 'pages#home'

      resources :activities, only: [:index]
      post 'activities/generate_report', to: 'activities#generate_report'
    end
  end
end
