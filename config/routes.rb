Rails.application.routes.draw do


  resources :google_client
  resources :session_replicas
  resources :lactic_sessions
  resources :lactic_matches
  resources :osm_subscribers
  resources :osm_sessions
  resources :sessions
  resources :users
  resources :homes
  resources :facebooks
  resources :notifications
  resources :user_infos
  # resources :lactic_locations
  # root to: 'users#index', via: :get
  root to: 'sessions#index', via: :get


  # get 'Log Out', to:'sessions#index'

  # get 'notifications/auth', to: 'notifications#auth'
  # post 'notifications/auth', to: 'notifications#auth'
  post 'notifications/auth', as: 'notifications_auth'
  post 'notifications/mock_auth', as: 'notifications_mock_auth'

  get 'auth/facebook', as: "auth_provider"
  get 'auth/facebook/callback', to: 'users#login'
  get 'users/login', to: 'users#login'
  get 'users/callback', to: 'users#callback'
  post 'users/callback', to: 'users#callback'
  get 'users/parse_facebook_cookies', to: 'users#parse_facebook_cookies'
  # post 'users/callback', to: 'users#callback'
  # get 'homes', to: 'homes#index'
  get 'users/index', to: 'users#index'
  get 'lactic_in', to: 'users#lactic_in'
  get 'facebook_code_auth', to: 'users#facebook_code_auth'
  # get 'auth/facebook', to: 'users#index'





  get 'notifications', to: 'notifications#notification_center'
  post 'notifications', to: 'notifications#notification_center'
  get 'profile', to: 'users#show'
  get 'confirm_email', to: 'users#confirm_email'
  get 'sign_out', to: 'sessions#sign_out'
  # get 'location_share', to: 'lactic_locations#share_location'
  # post 'location_share', to: 'lactic_locations#share_location'
  # get 'osms', to: 'osm_sessions#index'
  # post 'osms', to: 'osm_sessions#index'


  get 'about', to: 'sessions#about_lactic'
  post 'about', to: 'sessions#about_lactic'

  get 'lactic_tour', to: 'sessions#lactic_tour'
  post 'lactic_tour', to: 'sessions#lactic_tour'

  get 'quick_create', to: 'lactic_matches#quick_create'
  post 'quick_create', to: 'lactic_matches#quick_create'


  get 'reset_notifications', to: 'notifications#reset_notifications'
  post 'reset_notifications', to: 'notifications#reset_notifications'


  get 'lacticate_screen', to: 'sessions#lacticinc'
  post 'lacticate_screen', to: 'sessions#lacticinc'

 get 'google_sign_in_confirm', to: 'users#google_sign_in_confirm'
  post 'google_sign_in_confirm', to: 'users#google_sign_in_confirm'

  get 'google_sign_in', to: 'users#google_sign_in'
  post 'google_sign_in', to: 'users#google_sign_in'


  get 'instagram_code_callback', to: 'instagram#code_callback'
  post 'instagram_code_callback', to: 'instagram#code_callback'


  get 'edit_lactic_instagram_image', to: 'lactic_sessions#edit_lactic_instagram_image'
  post 'edit_lactic_instagram_image', to: 'lactic_sessions#edit_lactic_instagram_image'

  get 'instagram_token_callback', to: 'instagram#token_callback'
  post 'instagram_token_callback', to: 'instagram#token_callback'


  get 'lactics', to: 'lactic_sessions#index'
  post 'lactics', to: 'lactic_sessions#index'




  get 'lactic_google_calendar_redirect', to: 'google_client#lactic_google_calendar_redirect'
  post 'lactic_google_calendar_redirect', to: 'google_client#lactic_google_calendar_redirect'

  # get 'lactic_google_plus_redirect', to: 'google_client#lactic_google_plus_redirect'
  # post 'lactic_google_plus_redirect', to: 'google_client#lactic_google_plus_redirect'



  get 'google_init', to: 'google_client#google_init'
  post 'google_init', to: 'google_client#google_init'
  match "/lactic_google_calendar_redirect" => 'google_client#lactic_google_calendar_redirect', via: :post




  # get 'osm_sessions/setup_osm_weekly_schedule', to: 'osm_sessions#setup_osm_weekly_schedule'
  get 'lactic_sessions/set_weekly_schedule', to: 'lactic_sessions#set_weekly_schedule'
  get 'search', to: 'users#search_lactic_user'
  post 'search', to: 'users#search_lactic_user'
  get 'settings', to: 'users#settings'

  get 'update_user_info', to: 'users#update_user_info'
  post 'update_user_info',to: 'users#update_user_info'


 get 'login_google_lactic_user', to: 'users#login_google_lactic_user'
  post 'login_google_lactic_user',to: 'users#login_google_lactic_user'

  get 'remove_about_info', to: 'users#remove_about_info'
  post 'remove_about_info',to: 'users#remove_about_info'

  get 'delete_lactic_session', to: 'lactic_sessions#delete_lactic_session'
  post 'delete_lactic_session',to: 'lactic_sessions#delete_lactic_session'

  get 'set_locations', to: 'lactic_sessions#set_locations'
  post 'set_locations',to: 'lactic_sessions#set_locations'


  # get 'lacticate_request', to: 'users#lacticate_request'
  # post 'lacticate_request', to: 'users#lacticate_request'

  get 'profile/edit', to: 'users#edit'

  get 'osms/new', to: 'osm_sessions#new'
  get 'lactics/new', to: 'lactic_sessions#new'

  # get 'schedule', to: 'osm_sessions#schedule'
  get 'weekly_schedule', to: 'lactic_sessions#weekly_schedule'

  # get '/show_public', to: 'osm_sessions#show_public'
  get '/show_public', to: 'lactic_sessions#show_public'
  post '/show_public', to: 'lactic_sessions#show_public'


  # get 'lactic_sessions/ical', to: 'lactic_sessions#ical'
  # post 'lactic_sessions/ical', to: 'lactic_sessions#ical'

  get '/', to: 'sessions#index'
  get '/logout', to: 'sessions#logout'
  get "/follow_osm_user_by_id", to: 'users#follow_osm_user_by_id'


  # post '/public_profile', to: 'users#public_profile', :as => :osm_profile
  # post  'osm_sessions/:id/vote_for' => 'osm_sessions#vote_for', :as => :vote_for
  post  'lactic_sessions/:id/vote_on' => 'lactic_sessions#vote_on', :as => :vote_on


  get  'skill_vote' ,to: 'users#skill_vote'
  post  'skill_vote' ,to: 'users#skill_vote'

  # post  'users/:id/skill_vote' => 'users#skill_vote', :as => :skill_vote
  # post  'notifications/auth' => 'notifications#auth', :as => :notifications_auth
  # get  'notifications/auth' => 'notifications#auth', :as => :notifications_auth







  # post  'users/search_nearby' => 'users#search_nearby', :as => :search_nearby

  get 'search_nearby', to: 'users#search_nearby'
  post 'search_nearby',to: 'users#search_nearby'



  get 'send_email', to: 'users#send_email'
  post 'send_email',to: 'users#send_email'



  post  'lactic_sessions/:id/remove_invite' => 'lactic_sessions#remove_invite', :as => :remove_invite




  # post  'lactic_sessions/:id/invite_to' => 'lactic_sessions#invite', :as => :invite_to
  # post  'lactic_sessions/:id/comment_on' ,to: 'lactic_sessions#comment_on', :as => :comment_on
  get  'comment_on' ,to: 'lactic_sessions#comment_on'
  post  'comment_on' ,to: 'lactic_sessions#comment_on'
 get  'invite' ,to: 'lactic_sessions#invite'
  post  'invite' ,to: 'lactic_sessions#invite'

  get  'fb_invite' ,to: 'lactic_sessions#fb_invite'
  post  'fb_invite' ,to: 'lactic_sessions#fb_invite'

  # get  '/fetch_invites' ,to: 'notifications#fetch_invites'
  # post  '/fetch_invites' ,to: 'notifications#fetch_invites'



  get  '/fetch_notification' ,to: 'notifications#fetch_notification'
  post  '/fetch_notification' ,to: 'notifications#fetch_notification'


  # get  'email/email_notification' ,to: 'notifications#email_notification'
  # post  'email/email_notification' ,to: 'notifications#email_notification'

  # post  'lactic_sessions/vote_on' => 'lactic_sessions#vote_on', :as => :vote_on


  # post '/search', to: 'users#public_profile'
  # put "/search/:id" => "users#public_profile"
  match '/search' => 'users#public_profile', via: :post
  get '/public_profile',to: 'users#public_profile'
  post '/public_profile',to: 'users#public_profile'
  # get 'public_user_osm_sessions',to: 'osm_sessions#public_user_osm_sessions'
  # get 'public_user_lactic_sessions',to: 'osm_sessions#public_user_osm_sessions'
  # post 'public_user_osm_sessions',to: 'osm_sessions#public_user_osm_sessions'



  get 'lactic_request',to: 'lactic_matches#lactic_request'
  post 'lactic_request',to: 'lactic_matches#lactic_request'




  mount PostgresqlLoStreamer::Engine => "/user_info_picture"
  # resources :osm_sessions, :except => ['show']
  # get    'osms/:osm_id/' => 'osm_sessions#show', :as => 'post'
  # post 'osm_sessions/public_user_osm_sessions',to: 'osm_sessions#public_user_osm_sessions'
  # get 'search?id', to: 'osm_sessions#public_user_osm_sessions'
  # get '/homes/:id', to:'homes/index', action:'homes/:id'
  match '*path' => redirect('/'), via: :get

  get '*path' => redirect('/')

  # match '*path', via: [:options], to:  lambda {|_| [204, {'Content-Type' => 'text/plain'}, []]}
  # resources :osm_sessions do
  #
  #   member do
  #     get :vote_for, to: 'osm_sessions#vote_for'
  #     # , :vote_against
  #   end
  # end

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

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
