# == Route Map
#
#                                 Prefix Verb      URI Pattern                                                                  Controller#Action
#                     sort_project_tasks POST      /projects/:project_id/tasks/sort(.:format)                                   tasks#sort
#               new_import_project_tasks GET       /projects/:project_id/tasks/new_import(.:format)                             tasks#new_import
#                   import_project_tasks POST      /projects/:project_id/tasks/import(.:format)                                 tasks#import
#            assigned_to_me_project_task PATCH     /projects/:project_id/tasks/:id/assigned_to_me(.:format)                     tasks#assigned_to_me
#                 set_state_project_task PATCH     /projects/:project_id/tasks/:id/set_state(.:format)                          tasks#set_state
#                  project_task_comments GET       /projects/:project_id/tasks/:task_id/comments(.:format)                      comments#index
#                                        POST      /projects/:project_id/tasks/:task_id/comments(.:format)                      comments#create
#               new_project_task_comment GET       /projects/:project_id/tasks/:task_id/comments/new(.:format)                  comments#new
#              edit_project_task_comment GET       /projects/:project_id/tasks/:task_id/comments/:id/edit(.:format)             comments#edit
#                   project_task_comment GET       /projects/:project_id/tasks/:task_id/comments/:id(.:format)                  comments#show
#                                        PATCH     /projects/:project_id/tasks/:task_id/comments/:id(.:format)                  comments#update
#                                        PUT       /projects/:project_id/tasks/:task_id/comments/:id(.:format)                  comments#update
#                                        DELETE    /projects/:project_id/tasks/:task_id/comments/:id(.:format)                  comments#destroy
#                          project_tasks GET       /projects/:project_id/tasks(.:format)                                        tasks#index
#                                        POST      /projects/:project_id/tasks(.:format)                                        tasks#create
#                       new_project_task GET       /projects/:project_id/tasks/new(.:format)                                    tasks#new
#                      edit_project_task GET       /projects/:project_id/tasks/:id/edit(.:format)                               tasks#edit
#                           project_task GET       /projects/:project_id/tasks/:id(.:format)                                    tasks#show
#                                        PATCH     /projects/:project_id/tasks/:id(.:format)                                    tasks#update
#                                        PUT       /projects/:project_id/tasks/:id(.:format)                                    tasks#update
#                                        DELETE    /projects/:project_id/tasks/:id(.:format)                                    tasks#destroy
#            project_discussion_comments GET       /projects/:project_id/discussions/:discussion_id/comments(.:format)          comments#index
#                                        POST      /projects/:project_id/discussions/:discussion_id/comments(.:format)          comments#create
#         new_project_discussion_comment GET       /projects/:project_id/discussions/:discussion_id/comments/new(.:format)      comments#new
#        edit_project_discussion_comment GET       /projects/:project_id/discussions/:discussion_id/comments/:id/edit(.:format) comments#edit
#             project_discussion_comment GET       /projects/:project_id/discussions/:discussion_id/comments/:id(.:format)      comments#show
#                                        PATCH     /projects/:project_id/discussions/:discussion_id/comments/:id(.:format)      comments#update
#                                        PUT       /projects/:project_id/discussions/:discussion_id/comments/:id(.:format)      comments#update
#                                        DELETE    /projects/:project_id/discussions/:discussion_id/comments/:id(.:format)      comments#destroy
#                    project_discussions GET       /projects/:project_id/discussions(.:format)                                  discussions#index
#                                        POST      /projects/:project_id/discussions(.:format)                                  discussions#create
#                 new_project_discussion GET       /projects/:project_id/discussions/new(.:format)                              discussions#new
#                edit_project_discussion GET       /projects/:project_id/discussions/:id/edit(.:format)                         discussions#edit
#                     project_discussion GET       /projects/:project_id/discussions/:id(.:format)                              discussions#show
#                                        PATCH     /projects/:project_id/discussions/:id(.:format)                              discussions#update
#                                        PUT       /projects/:project_id/discussions/:id(.:format)                              discussions#update
#                                        DELETE    /projects/:project_id/discussions/:id(.:format)                              discussions#destroy
# resend_invitation_project_contribution POST      /projects/:project_id/contributions/:id/resend_invitation(.:format)          contributions#resend_invitation
#                  project_contributions GET       /projects/:project_id/contributions(.:format)                                contributions#index
#                                        POST      /projects/:project_id/contributions(.:format)                                contributions#create
#               new_project_contribution GET       /projects/:project_id/contributions/new(.:format)                            contributions#new
#              edit_project_contribution GET       /projects/:project_id/contributions/:id/edit(.:format)                       contributions#edit
#                   project_contribution GET       /projects/:project_id/contributions/:id(.:format)                            contributions#show
#                                        PATCH     /projects/:project_id/contributions/:id(.:format)                            contributions#update
#                                        PUT       /projects/:project_id/contributions/:id(.:format)                            contributions#update
#                                        DELETE    /projects/:project_id/contributions/:id(.:format)                            contributions#destroy
#            download_project_attachment POST      /projects/:project_id/attachments/:id/download(.:format)                     attachments#download
#            project_attachment_comments GET       /projects/:project_id/attachments/:attachment_id/comments(.:format)          comments#index
#                                        POST      /projects/:project_id/attachments/:attachment_id/comments(.:format)          comments#create
#         new_project_attachment_comment GET       /projects/:project_id/attachments/:attachment_id/comments/new(.:format)      comments#new
#        edit_project_attachment_comment GET       /projects/:project_id/attachments/:attachment_id/comments/:id/edit(.:format) comments#edit
#             project_attachment_comment GET       /projects/:project_id/attachments/:attachment_id/comments/:id(.:format)      comments#show
#                                        PATCH     /projects/:project_id/attachments/:attachment_id/comments/:id(.:format)      comments#update
#                                        PUT       /projects/:project_id/attachments/:attachment_id/comments/:id(.:format)      comments#update
#                                        DELETE    /projects/:project_id/attachments/:attachment_id/comments/:id(.:format)      comments#destroy
#                    project_attachments GET       /projects/:project_id/attachments(.:format)                                  attachments#index
#                                        POST      /projects/:project_id/attachments(.:format)                                  attachments#create
#                 new_project_attachment GET       /projects/:project_id/attachments/new(.:format)                              attachments#new
#                edit_project_attachment GET       /projects/:project_id/attachments/:id/edit(.:format)                         attachments#edit
#                     project_attachment GET       /projects/:project_id/attachments/:id(.:format)                              attachments#show
#                                        PATCH     /projects/:project_id/attachments/:id(.:format)                              attachments#update
#                                        PUT       /projects/:project_id/attachments/:id(.:format)                              attachments#update
#                                        DELETE    /projects/:project_id/attachments/:id(.:format)                              attachments#destroy
#              get_events_project_events GET       /projects/:project_id/events/get_events(.:format)                            events#get_events
#                         project_events GET       /projects/:project_id/events(.:format)                                       events#index
#                                        POST      /projects/:project_id/events(.:format)                                       events#create
#                      new_project_event GET       /projects/:project_id/events/new(.:format)                                   events#new
#                     edit_project_event GET       /projects/:project_id/events/:id/edit(.:format)                              events#edit
#                          project_event GET       /projects/:project_id/events/:id(.:format)                                   events#show
#                                        PATCH     /projects/:project_id/events/:id(.:format)                                   events#update
#                                        PUT       /projects/:project_id/events/:id(.:format)                                   events#update
#                                        DELETE    /projects/:project_id/events/:id(.:format)                                   events#destroy
#         new_import_project_integration GET       /projects/:project_id/integrations/:id/new_import(.:format)                  integrations#new_import
#       start_import_project_integration POST      /projects/:project_id/integrations/:id/start_import(.:format)                integrations#start_import
#                   project_integrations GET       /projects/:project_id/integrations(.:format)                                 integrations#index
#                                        POST      /projects/:project_id/integrations(.:format)                                 integrations#create
#                new_project_integration GET       /projects/:project_id/integrations/new(.:format)                             integrations#new
#               edit_project_integration GET       /projects/:project_id/integrations/:id/edit(.:format)                        integrations#edit
#                    project_integration GET       /projects/:project_id/integrations/:id(.:format)                             integrations#show
#                                        PATCH     /projects/:project_id/integrations/:id(.:format)                             integrations#update
#                                        PUT       /projects/:project_id/integrations/:id(.:format)                             integrations#update
#                                        DELETE    /projects/:project_id/integrations/:id(.:format)                             integrations#destroy
#                               projects GET       /projects(.:format)                                                          projects#index
#                                        POST      /projects(.:format)                                                          projects#create
#                            new_project GET       /projects/new(.:format)                                                      projects#new
#                           edit_project GET       /projects/:id/edit(.:format)                                                 projects#edit
#                                project GET       /projects/:id(.:format)                                                      projects#show
#                                        PATCH     /projects/:id(.:format)                                                      projects#update
#                                        PUT       /projects/:id(.:format)                                                      projects#update
#                                        DELETE    /projects/:id(.:format)                                                      projects#destroy
#                      join_contribution GET       /contributions/:id/join(.:format)                                            contributions#join
#                       new_user_session GET       /users/sign_in(.:format)                                                     devise/sessions#new
#                           user_session POST      /users/sign_in(.:format)                                                     devise/sessions#create
#                   destroy_user_session DELETE    /users/sign_out(.:format)                                                    devise/sessions#destroy
#  user_google_oauth2_omniauth_authorize GET|POST  /users/auth/google_oauth2(.:format)                                          omniauth_callbacks#passthru
#   user_google_oauth2_omniauth_callback GET|POST  /users/auth/google_oauth2/callback(.:format)                                 omniauth_callbacks#google_oauth2
#        user_twitter_omniauth_authorize GET|POST  /users/auth/twitter(.:format)                                                omniauth_callbacks#passthru
#         user_twitter_omniauth_callback GET|POST  /users/auth/twitter/callback(.:format)                                       omniauth_callbacks#twitter
#          user_asana_omniauth_authorize GET|POST  /users/auth/asana(.:format)                                                  omniauth_callbacks#passthru
#           user_asana_omniauth_callback GET|POST  /users/auth/asana/callback(.:format)                                         omniauth_callbacks#asana
#           user_jira_omniauth_authorize GET|POST  /users/auth/jira(.:format)                                                   omniauth_callbacks#passthru
#            user_jira_omniauth_callback GET|POST  /users/auth/jira/callback(.:format)                                          omniauth_callbacks#jira
#         user_trello_omniauth_authorize GET|POST  /users/auth/trello(.:format)                                                 omniauth_callbacks#passthru
#          user_trello_omniauth_callback GET|POST  /users/auth/trello/callback(.:format)                                        omniauth_callbacks#trello
#                          user_password POST      /users/password(.:format)                                                    devise/passwords#create
#                      new_user_password GET       /users/password/new(.:format)                                                devise/passwords#new
#                     edit_user_password GET       /users/password/edit(.:format)                                               devise/passwords#edit
#                                        PATCH     /users/password(.:format)                                                    devise/passwords#update
#                                        PUT       /users/password(.:format)                                                    devise/passwords#update
#               cancel_user_registration GET       /users/cancel(.:format)                                                      devise_invitable/registrations#cancel
#                      user_registration POST      /users(.:format)                                                             devise_invitable/registrations#create
#                  new_user_registration GET       /users/sign_up(.:format)                                                     devise_invitable/registrations#new
#                 edit_user_registration GET       /users/edit(.:format)                                                        devise_invitable/registrations#edit
#                                        PATCH     /users(.:format)                                                             devise_invitable/registrations#update
#                                        PUT       /users(.:format)                                                             devise_invitable/registrations#update
#                                        DELETE    /users(.:format)                                                             devise_invitable/registrations#destroy
#                 accept_user_invitation GET       /users/invitation/accept(.:format)                                           devise/invitations#edit
#                 remove_user_invitation GET       /users/invitation/remove(.:format)                                           devise/invitations#destroy
#                        user_invitation POST      /users/invitation(.:format)                                                  devise/invitations#create
#                    new_user_invitation GET       /users/invitation/new(.:format)                                              devise/invitations#new
#                                        PATCH     /users/invitation(.:format)                                                  devise/invitations#update
#                                        PUT       /users/invitation(.:format)                                                  devise/invitations#update
#                          finish_signup GET|PATCH /users/:id/finish_signup(.:format)                                           omniauth_callbacks#finish_signup
#                      associate_account PATCH     /users/:id/associate_account(.:format)                                       omniauth_callbacks#associate_account
#            mark_all_read_notifications PATCH     /notifications/mark_all_read(.:format)                                       notifications#mark_all_read
#                          notifications GET       /notifications(.:format)                                                     notifications#index
#                                        POST      /notifications(.:format)                                                     notifications#create
#                       new_notification GET       /notifications/new(.:format)                                                 notifications#new
#                      edit_notification GET       /notifications/:id/edit(.:format)                                            notifications#edit
#                           notification GET       /notifications/:id(.:format)                                                 notifications#show
#                                        PATCH     /notifications/:id(.:format)                                                 notifications#update
#                                        PUT       /notifications/:id(.:format)                                                 notifications#update
#                                        DELETE    /notifications/:id(.:format)                                                 notifications#destroy
#                                   root GET       /                                                                            welcome#index
#                                        GET       /notifications(.:format)                                                     notifications#index
#                                        POST|HEAD /webhooks/:integration_id(.:format)                                          webhooks#create {:defaults=>{:formats=>:json}}
#

Rails.application.routes.draw do
  # mount API::Root => '/'

  resources :projects do
    resources :tasks do
      collection do
        post :sort
        get :new_import
        post :import
      end

      patch :assigned_to_me, :set_state, on: :member
      resources :comments
    end

    resources :discussions do
      resources :comments
    end

    resources :contributions do
      member do
        post 'resend_invitation'
      end
    end

    resources :attachments do
      member do
        post 'download'
      end
      resources :comments
    end

    resources :events do
      get :get_events, on: :collection
    end

    resources :integrations do
      member do
        get :new_import
        post :start_import
      end
    end
  end

  resources :contributions, only: :join do
    get :join, on: :member
  end


  devise_for :users, :controllers => {omniauth_callbacks: 'omniauth_callbacks'}

  devise_scope :user do
    match '/users/:id/finish_signup', :to => 'omniauth_callbacks#finish_signup', via: [:get, :patch], :as => :finish_signup
    match '/users/:id/associate_account', :to => 'omniauth_callbacks#associate_account', via: :patch, :as => :associate_account
  end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  resources :notifications do
    collection do
      patch 'mark_all_read'
    end
  end
  root 'welcome#index'
  get 'notifications' => 'notifications#index'

  #resource to receive VCS messages as a post request.
  # trello sending HEAD request
  match 'webhooks/:integration_id' => 'webhooks#create', defaults: {formats: :json}, via: [:post, :head]


  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
