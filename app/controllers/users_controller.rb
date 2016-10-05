# require 'monitor.rb'
# class UsersController < ApplicationController
class UsersController < LacticSessionsCommonController
  before_action :set_current_user, only: [:settings, :show, :public_profile]

  before_action :notification_center, only: [:show, :index, :search_lactic_user, :settings, :public_profile]
  # before_filter :init_location_nearby_list
  # before_action :init_location_nearby_list

  helper_method :public_profile
  helper_method :public_profile
  helper_method :get_osm_users_by_fbId
  helper_method :follow_osm_user_by_id
  helper_method :public_user_hashed
  helper_method :auth_facebook
  helper_method :update_user_keys
  helper_method :reset_current_user


  # def init_location_nearby_list
  #   @nearby_result ||= Array.new
  #   puts "SEARCH NEARBY IDS FROM INIT #{@nearby_result.inspect}"
  #
  # end

  def user_params
    params.permit(:osm_user_info).permit(:title)
  end
  def parse_facebook_cookies
    puts "IN PARSE FACEBOOK COOKIES CALLER #{caller[0].split("`").pop.gsub("'", "")}"
    begin
    @facebook_cookies ||= Koala::Facebook::OAuth.new(ENV["FACEBOOK_KEY"], ENV["FACEBOOK_SECRET"]).get_user_info_from_cookie(cookies)
    @access_token = @facebook_cookies['access_token']
    @access_token_expires_at = @facebook_cookies["expires"].to_i.seconds.from_now

    check_expired_and_update(@facebook_cookies)
    rescue
      scope = "&scope=public_profile,email,user_friends,user_actions.fitness"


      # @oauth = Koala::Facebook::OAuth.new('https://warm-citadel-1598.herokuapp.com/users/callback')
      @oauth =Koala::Facebook::OAuth.new('https://warm-citadel-1598.herokuapp.com/users/callback').url_for_oauth_code(:permissions => "public_profile,email,user_friends,user_actions.fitness")


      # url = "#{}#{scope}"
      # puts "PARSE FACEBOOK COOKIE RESCUE #{url}"
      redirect_to @oauth
    end

  end

  def re_auth
    @oauth = Koala::Facebook::OAuth.new('https://warm-citadel-1598.herokuapp.com/users/callback')
  end

  def callback
    puts "IN CALLBACK COOKIE FACEBOOK #{@facebook_cookies.inspect}"
    begin
    @facebook_cookies ||= Koala::Facebook::OAuth.new(ENV["FACEBOOK_KEY"], ENV["FACEBOOK_SECRET"])
    puts "IN CALLBACK COOKIE FACEBOOK #{@facebook_cookies.inspect}"
    facebook_code_auth
    rescue
      puts "IN CALLBACK COOKIE RESCUE AUTH FACEBOOK"
      # facebook_code_auth
    end

    redirect_to root_path


  end

  def facebook_code_auth
    facebook  = Facebook.new
    puts "IN FACEBOOK CODE AUTH"
    begin
    @oauth = Koala::Facebook::OAuth.new('https://warm-citadel-1598.herokuapp.com/users/callback')
    # @oauth = Koala::Facebook::OAuth.new('https://warm-citadel-1598.herokuapp.com/users/facebook_code_auth')
    puts "IN FACEBOOK CODE AUTH ??? #{@oauth.inspect}"
    @access_token = @oauth.get_access_token(params[:code])
    uid = cookies[:osm_respond_id]

    # puts "IN FACEBOOK CODE AUTH ??? #{@oauth.inspect}"
    facebook.access_token = @access_token
    facebook.uid =uid
    facebook.refresh_facebook_token
    # PostgresFacebook.update_facebook(facebook)
    facebook = FacebooksController.update_facebook_from_model(facebook)
    rescue Exception => e
    puts "EXCEPTION FROM FACEBOK #{e.message}"
    end

    facebook
  end

  def index

    if cookies[:lactic_mock_respond_id]
      login_mock_user
    else
      @access_token_cookie = cookies['current_access_token']
      @access_token_cookie_expires = cookies['current_access_token_expires_in']

      begin
        parse_facebook_cookies
      rescue Exception => e
        puts "EXCEPTION #{e.message}"
      end

    end


  end


  def login_mock_user
    # set_lactic_contacts(current_session_user.uid)

    redirect_to profile_path
  end


  def check_expired_and_update(auth)


    puts "PARAMS CODE ??? #{params[:code]}"
    facebook = (params[:code])? facebook_code_auth : auth_facebook(auth)

    if facebook
      puts "FROM USERS INDEX ON PG!!!!!"
      current_session_user = get_current_session_user
      if current_session_user && current_session_user.id
        current_session_user.access_token = facebook.access_token
        current_session_user.access_token_expiration_date = facebook.access_token_expiration_date || DateTime.now
        UsersController.update_user(current_session_user)
        FacebooksController.update_facebook(current_session_user)
        cookies.permanent[:current_access_token] = facebook.access_token
        cookies.permanent[:current_access_token_expires_in] = facebook.access_token_expiration_date

        set_lactic_fb_contacts(current_session_user.uid)
        # if cookies[:lactic_location] && cookies[:lactic_location] == 'on'
        #   get_nearest
        # end
        # if cookies[:osm_respond_id] == '10153011850791938'
        init_global_sessions
        # end
        redirect_to profile_path
      else
        puts "FROM USERS INDEX NOT ON PG"


        puts "GET CURRENT NOT ON PG USER COOKIE #{get_current_user_from_cookie.inspect}"
        user_from_omniauth = User.new
        user_from_omniauth.uid = cookies[:osm_respond_id]
        user_from_omniauth.id = cookies[:osm_respond_id].to_i

        user_from_omniauth.name =  cookies[:osm_name] || cookies[:lactic_name]
        user_from_omniauth.access_token = facebook.access_token
        user_from_omniauth.access_token_expiration_date = facebook.access_token_expiration_date
        user_from_omniauth.email = cookies[:lactic_email]
        # puts "FROM USERS INDEX NOT ON PG #{user_from_omniauth.inspect}"
        user_model = User.new
        puts "USER FROM OMNI #{user_from_omniauth.inspect}"
        user = user_model.new_save_from_user(user_from_omniauth)

        if user && !cookies[:lactic_mock_respond_id]
          cookies.permanent[:osm_respond_id] = cookies[:osm_id]

          set_user_cookie(user_from_omniauth)
          FacebooksController.authanticate(user_from_omniauth,facebook.access_token)
          set_lactic_fb_contacts(user_from_omniauth.uid)
          # if cookies[:lactic_location] && cookies[:lactic_location] == 'on'
          #   get_nearest
          # end
          # if cookies[:osm_respond_id] == '10153011850791938'
            init_global_sessions
          # end

          # new_user_notify_background(user_from_omniauth)

          redirect_to profile_path
        end

      end
      # send_friends_new_join(current_session_user)



    else
      puts "FACEBOOK ERROR AUTH!"
    end
  end


  def auth_facebook  oauth

    facebook = Facebook.new

    if !cookies[:lactic_mock_respond_id]
      cookies.permanent[:osm_respond_id] =  cookies[:osm_id]
      user= get_current_session_user
      set_user_cookie(user)
      facebook = FacebooksController.authanticate(user,oauth)
    else
      cookies.permanent[:osm_respond_id] = cookies[:lactic_mock_respond_id]
      set_user_cookie(get_mock_user)
    end

    facebook

  end

  def google_sign_in

    google_user = User.new
    if params[:google_access_token]
      ::GOOGLE_CALENDAR_CLIENT.login_with_refresh_token(params[:google_access_token])
      # puts "CALL FOR GOOGLE SIGN IN"
      # primary_email = get_primary_gmail
      google_user = google_plus
      session[:google_user_id] = google_user.id
      session[:google_user_name] = google_user.name
      session[:google_user_email] = google_user.email
      session[:google_user_picture] = google_user.picture
      session[:google_user_token] = google_user.google_token
    end
    respond_to do |format|
      format.html { redirect_to about_path(:gmail_sign_in => google_user)}
    end
  end

  def google_sign_in_confirm

    google_user = (params["user"] && !params["user"].empty?)? User.user_from_google_hash(params["user"]) : nil

    if google_user && google_user.id

      # puts "USER FROM  GOOGLE HASH #{google_user.inspect}"

      login_google_lactic_user(google_user)

    else
      puts "USER FROM  GOOGLE HASH FAILED!!!! "
      redirect_to about_path

    end

  end


  def login_google_lactic_user(google_user)
    pg_user = User.new
    pg_user.email =  google_user.email
    pg_user = pg_user.get_user_by_email

    response = nil
    if pg_user && pg_user.id
      ### USER ALREADY LACTIC - UPDATE AND SIGN IN
      ## only update picture,google_id and google token
      pg_user.picture =  google_user.picture
      pg_user.google_token = google_user.google_token
      pg_user.google_id = google_user.google_id

      puts "LOGON GOOGLE LACTIC USER UPDATE===== #{pg_user.inspect}"

      response = pg_user.update_google_user
      set_user_cookie(response)
    else
      ## NEW USER FROM GOOGLE ...
      puts "LOGON GOOGLE LACTIC USER SAVE ===== #{google_user.inspect}"
      response = google_user.save_google_user
      set_cookie_from_new_google(response)

    end
    # redirect_to about_path
    redirect_to profile_path

  end

  def set_cookie_from_new_google(google_user)
    cookies.permanent[:osm_respond_id] = google_user.id
    cookies.permanent[:lactic_email] = google_user.email
    cookies.permanent[:lactic_name] = google_user.name
    cookies.permanent[:lactic_google_id] = google_user.google_id
    cookies.permanent[:lactic_picture] = google_user.picture
  end

  ### LogIn with the current FB session user




  def lactic_in

    user = User.new

    user.uid = cookies[:lactic_mock_respond_id]? cookies[:lactic_mock_respond_id] : cookies[:osm_id]
    user.id = user.uid.to_i
    # @mock = cookies[:lactic_mock_respond_id]
    # puts "COOKIE SESSION #{cookies.inspect}"
    # @exchangeUrl = "https://graph.facebook.com/oauth/access_token?grant_type=fb_exchange_token&fb_exchange_token=#{cookies['accessToken']}&client_id=#{FACEBOOK_CONFIG['app_id']}&client_secret=#{FACEBOOK_CONFIG['secret']}"
    user.access_token = cookies['current_access_token']
    user.access_token_expiration_date = cookies['current_access_token_expires_in']
    user.email = cookies['lactic_email']

    user.name = cookies['lactic_name']


    user_model = User.new
    user = user_model.new_save_from_user(user)

    if user && !cookies[:lactic_mock_respond_id]
      cookies.permanent[:osm_respond_id] = cookies[:osm_id]

      set_user_cookie(user)
      FacebooksController.new_facebook_user(user)
      set_lactic_fb_contacts(user.uid)
      # new_user_notify_background(@user_from_omniauth)
      redirect_to profile_path
    else
      # cookies.permanent[:osm_respond_id] = cookies[:lactic_mock_respond_id]

      # login_mock_user

      puts "ERROR IN CALLBACK FROM FACEBOOK"
      # redirect_to url_for(:controller => :users, :action => :index) and return

      redirect_to root_path


    end

  end
  def login
    puts "IN LOGIN USERS CALLER #{caller[0].split("`").pop.gsub("'", "")}"



      @user_fb = User.koala(request.env['omniauth.auth']['credentials'])
      @user_from_omniauth = User.from_omniauth(env["omniauth.auth"],@user_fb['email'],@user_fb['picture']['data']['url'])
      session[:user_id] = @user_from_omniauth.uid

      access_token = request.env['omniauth.auth']['credentials']['token']

    user_model = User.new
    user = user_model.new_save_from_user(@user_from_omniauth)

      if user && !cookies[:lactic_mock_respond_id]
        cookies.permanent[:osm_respond_id] = cookies[:osm_id]

        set_user_cookie(@user_from_omniauth)
        FacebooksController.authanticate(@user_from_omniauth,access_token)
        set_lactic_fb_contacts(@user_from_omniauth.uid)
        # new_user_notify_background(@user_from_omniauth)
        redirect_to profile_path
      else
        # cookies.permanent[:osm_respond_id] = cookies[:lactic_mock_respond_id]

        # login_mock_user

        puts "ERROR IN CALLBACK FROM FACEBOOK"

        # redirect_to :back, :params => params[:url_params]
        # redirect_to root_path
        facebook_code_auth
        redirect_to root_path
        # redirect_to url_for(:controller => :users, :action => :index) and return

      end


  end

  # def new_user_notify_background(user)
  #   Thread.new {
  #     fb_lactic_friends = get_fb_conatcts(cookies[:osm_respond_id])
  #
  #     send_friends_new_join(user, fb_lactic_friends)
  #
  #
  #   }
  # end

  ## defined and thrown from config/initializers/omniauth.rb
  def oauth_failure
    puts "oauth_failure!!!!!! "
  end


  def settings
    # @user = get_current_session_user
    @user_info = UserInfo.new
    @user_info.id = @user.id
    @user_info = @user_info.get_user_info || UserInfo.new


    lautitude = (cookies[:lactic_latitude]) ? cookies[:lactic_latitude].to_f : nil
    longitude = (cookies[:lactic_longitude])?cookies[:lactic_longitude].to_f : nil

    @user_info.latitude = lautitude
    @user_info.longitude = longitude
    @user_info.name = @user.name



    # presence_channel_users ('presence-instructor')
    # presence_channel_users ('presence-dancer')
    # puts "USER INFO #{@user_info.inspect}"


  end


  def search_keyword_users(keywords)

  end

  def read_image(oid, body)
    lo = USERS_POSTGRES_CONNECTION.lo_open(oid, ::PG::INV_READ)
    while (data = USERS_POSTGRES_CONNECTION.lo_read(lo, 4096))
      body << data
    end
    USERS_POSTGRES_CONNECTION.lo_close(lo)
  end





  def show
    my_uploader = AvatarUploader.new

    puts "IN USER SHOW PAPRAM #{params.inspect}"
    if (params[:code] && (!cookies[:lactic_mock_respond_id] || cookies[:lactic_mock_respond_id].empty?))

      check_expired_and_update(nil)
      # set_current_user
    end

    if  session[:instagram_access_token]
       # puts "SESSION INSTAGRAM ACCESS #{session[:instagram_access_token]}"
       inst_user = instagram_user
       @instagram_pic =  inst_user[:picture]
       @album =  inst_user[:album]
       @lactic_instagram_images=  inst_user[:lactic_instagram_images]
       @instagram_link = inst_user[:url]
    end

    ## creating session from the profile
    @lactic_session = LacticSession.new
    @repeat_options =  [["Weekly",1],["Once",0]]


    # puts "SHOW PROFILE USERS CONTROLLER METHOD save #{caller[0].split("`").pop.gsub("'", "")} FOR UID == #{cookies[:osm_respond_id]}"



    # @user_info = @user.get_user_info
    @user_info = UserInfo.new
    # puts "USER INFO TEST #{@user_info.inspect}"
    @user_info.id = @user.id
    @user_info = @user_info.get_user_info || UserInfo.new
    @user_info.name ||= @user.name



    if !@user_info.public_service
      lautitude = (cookies[:lactic_latitude]) ? cookies[:lactic_latitude].to_f : nil
      longitude = (cookies[:lactic_longitude])?cookies[:lactic_longitude].to_f : nil
      @user_info.latitude = lautitude
      @user_info.longitude = longitude
    end


    # if @user_info.keywords_rated
    #   @user_info.keywords_rated.each do |keyword,voted|
    #     puts "KEYWORDS RATED FOR  #{keyword} VOTED #{voted.inspect}"
    #   end
    # end

    # puts "DEF SHOW USER before PICTURE #{@user.picture}"

    @user.picture =(@user.picture && !@user.picture.empty?)? @user.picture :  "https://graph.facebook.com/#{@user.uid}/picture?type=large"

   # puts "DEF SHOW USER PICTURE #{@user.picture}"

    # if cookies[:osm_respond_id] == '10153011850791938'

    weekly_sessions = get_global_var(@user.uid)[:weekly_sessions]
      @lactic_sessions = (weekly_sessions && !weekly_sessions.empty?)? weekly_sessions.values.flatten : Array.new
      @lactic_sessions_hash = get_global_var(@user.uid)[:hash_sessions]


    # else
    #   lactic_sessions_promoted = get_all_between(DateTime.now.beginning_of_day,DateTime.now.beginning_of_day+7.days, @user,@user)
    #
    #   @lactic_sessions = (lactic_sessions_promoted && lactic_sessions_promoted[:sessions])?lactic_sessions_promoted[:sessions]:[]
    #
    #
    #
    #   @lactic_sessions_hash ||= (lactic_sessions_promoted && lactic_sessions_promoted[:hash_sessions])?  lactic_sessions_promoted[:hash_sessions]:[]


    # end

    if cookies[:osm_respond_id] == '10153011850791938'


      @lactic_requests = LacticMatchesController.get_mock_requets

    else
      @lactic_requests = LacticMatchesController.get_user_pending_requests(@user)


    end



    if cookies[:osm_respond_id] == '10153011850791938'
      ## TESTING WESTWOOD LA LOCATIONS
      lat = 34.0635
      longt = -118.4455
      ## TESTING SANTA MONICA LA LOCATIONS
      # lat = 34.0195
      # longt = -118.4912

      ## TESTING Marina del Rey LA LOCATIONS 33.9803° N, 118.4517° W
      # lat = 33.9803
      # longt = -118.4517

      ## TESTING Marina Georgetown University/Coordinates  38.9076° N, 77.0723° W
      # lat = 38.9076
      # longt = 77.0723
      ## TESTING 32.0853° N, 34.7818° E TEL AVIV
      # lat = 32.0853
      # longt = 34.7818


      @nearest_locations = nearby_locations(lat , longt)
      # instagram_user
    else
      if LacticLocation.valid_coordinates(cookies[:lactic_latitude] ,  cookies[:lactic_longitude])
        ### IN CASE THE USER'S LOCATION IS OFF - SHOW LAST LOCATION CHECK IN PLACES...

        lat = cookies[:lactic_latitude]
        longt = cookies[:lactic_longitude]
      else
        lat = @user_info.latitude
        longt = @user_info.longitude
      end
      @nearest_locations = LacticLocation.valid_coordinates(lat,longt) ? nearby_locations(lat , longt) : Array.new











    end


    if params[:google_access_token]
      ::GOOGLE_CALENDAR_CLIENT.login_with_refresh_token(params[:google_access_token])
      puts "CALL FOR CALENDAR GOOGLE"
      # send_event_test
      # get_primary_gmail
      google_plus
    end






  # end
  end




  def send_email
    if cookies[:osm_respond_id] == '10153011850791938'
      # puts "SEND NOTIFICATION #{DateTime.now}"
      user_to = User.new
      user_to.email = params[:send_to_email]
      # user_to.email = 'sharonanachum@gmail.com'
      user_to.name = params[:send_to_name]
      user_to.id = params[:send_to_id]

      if user_to.email && user_to.name
        email_notification(user_to)
        # email_lactic_create(user_to)
        # email_lactic_partner(user_to)
      end
      #
      # user_to.email = params[:send_to_email]
      # puts "SEND EMAIL NOTOIFIACTION TO #{user_to.inspect}"
    end


    respond_to do |format|
      # format.html {redirect_to profile_path }
      format.html {redirect_to :back, :params => params[:url_params]}
    end
  end







  def edit

  end

  ## save all Users contacts to retrieve on  DB
  def set_lactic_fb_contacts(uid)
    Thread.new {
      # FacebooksController.set_lactic_contacts(uid)
      FacebooksController.set_facebook_contacts(uid)
    }
  end


  def save_users_retrieve(uid,contacts)
    facebook_friends_json = ''

    facebook_friends_uids = []

    if contacts && !(contacts.empty?)
      contacts.each do |user|
        facebook_friends_json.concat("{'name' : '#{user[:name].gsub("'", '')}','id' : '#{user[:id]}', 'picture' : '#{user[:picture].gsub("\\\\\\\\u0026", '&').gsub("\\\\u0026", '&')}'},".gsub("'", '"'))
        facebook_friends_uids << user[:id]
      end
      facebook_friends_json = '[' + facebook_friends_json + ']'
      facebook_friends_json = facebook_friends_json.gsub(',]', ']')

    end
    save_contacts_retrieve(uid,facebook_friends_json,true,facebook_friends_uids)

  end

  def self.get_contacts(id)
    contacts = {}
    if id
      user_model = User.new

      ## Fetching from last retrieve...
      non_lactic = user_model.lactic_contacts(id, false)
      lactic = user_model.lactic_contacts(id,true)

      # ## Fetching all LACtic users
      # all_users = user_model.all_lactic_users(uid)

      contacts = {:non_lactic =>non_lactic, :lactic => lactic }
    end
    contacts
  end

  def self.get_all_contacts(email)
    # ## Fetching all LACtic users
    user_model = User.new
    user_model.all_lactic_users(email)
  end

  # def get_fb_conatcts (user_uid)
  #   lactic = {}
  #   if user_uid
  #     user_model = User.new
  #     lactic = user_model.lactic_contacts(user_uid,true)
  #   end
  #   lactic
  # end


  def get_all_conatacts

  end


  def self.save_hashed_fb_contacts(uid,facebook_friends_json)
    if uid && facebook_friends_json
      user_model = User.new
      user_model.save_fb_hashed_contacts(uid,facebook_friends_json)
    end

  end

###TO DO - ADDING RETRIEVE ALL LACTIC USERS...
  def self.save_contacts_retrieve(uid,facebook_friends,lactic_contacts,facebook_friends_uids)
    user_model = User.new
    user_model.save_contacts_retrieve(uid,facebook_friends,lactic_contacts)
  end


  def self.get_lactic_non_fb_friends(uid,fb_friends_uids)
    contacts  = ''

    if uid
      user_model = User.new
      contacts_users = user_model.get_lactic_non_fb_friends(uid,fb_friends_uids)
      contacts  = user_model.user_to_json_string(contacts_users)

    end

    contacts
  end

  def search_lactic_user

    @user_info = UserInfo.new
    # keywords = params[:user_info]["keywords_about"] || params[:user_info]["keywords_service_about"]
    @user_info.keywords_about = (params[:user_info] && params[:user_info]["keywords_about"] )? params[:user_info]["keywords_about"] : ''
    # puts "IN SEARCH CALLER #{caller[0].split("`").pop.gsub("'", "")} PARAMS #{params.inspect}"
    # puts "IN SEARCH FILTER WITH #{@user_info.keywords_about.inspect}"

    @current_search_engine_keys ||= Array.new



    @current_search_engine_keys = (params[:engine_search])? params[:engine_search] : @current_search_engine_keys
    json_result = contacts(false)
    json_result2 = contacts(true)
    # @contacts  = json_result
    @non_contacts  = contacts(false)
    @contacts  = contacts(true)

    @filter_search_result = filter_search(@user_info.keywords_about)
    # puts "FILTER SEARCH #{@filter_search_result.inspect}"

    if @filter_search_result && @filter_search_result.length > 0
      @contacts.each do |contact|
        if !@filter_search_result.include? contact["id"]
          contact["filtered"] = true
        end
      end
    end


    # @filtered = Array.new
    # filter_search_result.each do |keyword, users_keywords|
    #   if
    # end
    @nearby_result = (@current_search_engine_keys && (@current_search_engine_keys.include? 'nearby'))? nearby_users(cookies[:lactic_latitude],cookies[:lactic_longitude])[:users_ids] : Array.new
    # puts "SEARCH NEARBY IDS from search #{@nearby_result.inspect}  INCLUDE ???  #{@nearby_result.include? "223246951357816"}"

    # @keywords_users
    # presence_channel_users('presence-traine')

  end


  def filter_search(filter_search_array_string)
    filter_search_result = Array.new

    if filter_search_array_string && !filter_search_array_string.empty?

      user_model = User.new
      filter_search_result = user_model.users_by_keywords_ids(filter_search_array_string)

    end


    filter_search_result
  end


  def add_key_search
    # @nearby_result = nearby_users(cookies[:lactic_latitude],cookies[:lactic_longitude])[:users_ids]
    @current_search_engine_keys ||= Array.new

    @current_search_engine_keys = (params[:engine_search])?(params[:engine_search]) : @current_search_engine_keys

    if (params[:keyword] && !params[:keyword].empty?)
      @current_search_engine_keys << params[:keyword]
    end


    respond_to do |format|
      format.html {redirect_to( search_path({:engine_search => @current_search_engine_keys}) ) }
    end
  end



  def search_nearby
    # @nearby_result = nearby_users(cookies[:lactic_latitude],cookies[:lactic_longitude])[:users_ids]
    @current_search_engine_keys ||= Array.new

    @current_search_engine_keys = (params[:engine_search])? (params[:engine_search]) : @current_search_engine_keys

    if !@current_search_engine_keys.include? 'nearby'
      @current_search_engine_keys << 'nearby'
    end
    respond_to do |format|
      format.html {redirect_to( search_path({:engine_search => @current_search_engine_keys}) ) }
    end


  end


  def init_osm_public_hash
    params[:shared_param__] ||= @osm_sessions_hash
  end





  def public_profile

    if (params[:id] == cookies[:osm_respond_id])
      # if @public_user.id == cookies[:osm_respond_id]
        redirect_to profile_path
    else
      user_model = User.new
      @public_user = user_model.get_user_by_fbID(params[:id],true)
      @fb_invite_sent = session[:fb_invite_sent]
      if @public_user

        @lactic_match = LacticMatch.new
        @lactic_match.requestor = @user.id.to_s
        @lactic_match.requestor_name = @user.name
        @lactic_match.status = "pending"
     ### fetching osm_sessions for a week period of time starting from today...
        @lactic_match.responder = @public_user.id.to_s
        lactic_match_requested = LacticMatchesController.request_sent @lactic_match
        if !lactic_match_requested
          opposite_request = LacticMatch.new
          opposite_request.requestor =  @lactic_match.responder
          opposite_request.responder = @lactic_match.requestor
          opposite_request_requetsed = LacticMatchesController.request_sent opposite_request
          if  !opposite_request_requetsed
            @lactic_match.responder_name = @public_user.name
          else
            @lactic_match = opposite_request_requetsed
          end
        else
          @lactic_match = lactic_match_requested
        end
        @public_user.picture = (@public_user.picture && !@public_user.picture.empty?)? @public_user.picture : "https://graph.facebook.com/#{@public_user.uid}/picture?type=large"
        @public_user.name = PostgresHelper.unescape_title_descriptions(@public_user.name)


        @user_info = UserInfo.new
        @user_info.id = @public_user.id
        @user_info = @user_info.get_user_info || UserInfo.new
        @user_info.name ||= @public_user.name
        matched_user_uid = (@public_user.matched_user_model)
        hashed_sessions = get_all_between(DateTime.now.beginning_of_day,DateTime.now.beginning_of_day+7.days, @public_user,@user)
        @lactic_sessions = (hashed_sessions && hashed_sessions[:sessions])?hashed_sessions[:sessions]:[]
    else
      if params[:id]
        hashed_fb_friends_result = @user.get_hashed_fb_friends
        hashed_fb_friends_json = nil
        if hashed_fb_friends_result
          public_user  = @user.hashed_json_contacts_to_json_string(hashed_fb_friends_result,params[:id])
        end
        if public_user
          @public_user = User.new
          @public_user.name = public_user["name"]
          @public_user.name = PostgresHelper.unescape_title_descriptions(@public_user.name)

          @public_user.picture = public_user["picture"]
          @public_user.id = public_user["name"]
        end
        @user_info = UserInfo.new
      end


      # if @user_info.keywords_rated
      #   @user_info.keywords_rated.each do |keyword,voted|
      #     puts "KEYWORDS RATED FOR  #{keyword} VOTED #{voted.inspect}"
      #   end
      # end



    end

    end
  end


  def public_user_hashed(current_user)
    hashed_fb_friends_result = current_user.get_hashed_fb_friends
    hashed_fb_friends_json = nil
    if hashed_fb_friends_result
      hashed_fb_friends_json  = User.hashed_json_contacts_to_json_string(hashed_fb_friends_result,params[:id])
    end
    hashed_fb_friends_json
  end

  def create
    user_model = User.new
   @public_osm_user = user_model.get_user_by_fbID(params[:user][:id],true)
   if (@public_osm_user)
    respond_to do |format|
      if @public_osm_user
          format.html  { redirect_to( public_profile_url({:id => @public_osm_user.id, :name => @public_osm_user.name, :picture => @public_osm_user.picture}),
                                      ) }
          format.json  { render :json => @public_osm_user}
      else
      end
    end
   end
  end

  def self.get_osm_users_by_fbId(uid)
    user_model = User.new
    user_model.get_user_by_fbID(uid,true)
  end
  ## Gets user model and update the PARSE user
  def self.update_user(user)
    user_model = User.new
    user_model.update_user(user)
  end

  def self.lacticate_users(responder_user, requestor_user)
    user_model = User.new
    user_model.lacticate_users(responder_user, requestor_user)
  end



  def update_user_info
    user_info = UserInfo.new
    user_info_params = params[:user_info]

    user_info.id = (user_info_params["id"] && !user_info_params["id"].empty?)? user_info_params["id"] : cookies[:osm_respond_id]

    user_info.name =  cookies[:lactic_name]
    user_info.set_info_from_view(user_info_params,params[:user_about])



    # subscribe_to_keywords(user_info.keywords_about)

    user_info_updated = (user_info_params["id"] && !user_info_params["id"].empty?)? user_info.update_info : user_info.save_new_info

    user_info_updated.keywords_about = user_info.keywords_about
    # user_info_updated.current_keywords = user_info.current_keywords

    # puts "USER INFO UPDATED #{user_info_updated.inspect}"

    update_user_keys(user_info_updated)


    update_user_name(user_info_updated)

    # puts "UPDATE USER INFO WITH #{user_info_params.inspect}"

    redirect_to profile_path
  end


  def update_user_name(user_info)
    if user_info && user_info.name && !user_info.name.empty? && user_info.name != cookies[:lactic_name]
      user = User.new
      result = user.update_name(user_info)
      if result
        cookies[:lactic_name] = user_info.name
      end


    end
  end

  def update_user_keys (user_info)
    if user_info.keywords_about && !user_info.keywords_about.empty?

      user_keyword = User.new
      user_keyword.id = user_info.id
      # user_keyword.uid = user_info.id
      user_keyword.name = user_info.name


      user_info.keywords_about.each do |keyword|
        user_keyword.add_user_keyword(keyword)
      end
      user_info.update_keywords_rated(user_info.id, user_info.keywords_about)
    end

  end

  def confirm_email

  end

  def remove_about_info
    user_info = UserInfo.new
    index = (params[:index])? params[:index].to_i : -1
    user_info.id = (params[:id] && !params[:id].empty?)? params[:id] : cookies[:osm_respond_id]
    user_info.about = params[:user_about]
    user_info.name = params[:name]
    user_info.title = params[:title]
    user_info.latitude = params[:latitude]
    user_info.longitude = params[:longitude]
    user_info.public_service = params[:public_service]
    if index > -1 && index < params[:user_about].length
      user_info.remove_about_text(index)
    end
    redirect_to profile_path
  end



  def self.global_weekly_unmatch_lactic
    user_model = User.new
    user_model.global_weekly_unmatch_lactic
  end



  def set_current_user




    @user = User.new
    @user.name = cookies[:lactic_name]
    @user.email = cookies[:lactic_email]


    if cookies[:osm_respond_id] && !cookies[:osm_respond_id].empty?
      @user.id = cookies[:osm_respond_id].to_i
      @user.uid = cookies[:lactic_fb_id]

      @user.matched = cookies[:lactic_matched]

      cookies.permanent[:lactic_picture] = (cookies[:lactic_picture]&& !cookies[:lactic_picture].empty? )? cookies[:lactic_picture] : ''


      @user.picture = cookies[:lactic_picture]


      # puts "FIRST PICTURE SETTINGS AFTER SIGN IN #{@user.picture}"

      if @user.matched
        matched = User.new
        matched.id = cookies[:lactic_matched_id]
        if !cookies[:lactic_matched_picture] || cookies[:lactic_matched_picture].empty?

          matched = matched.get_user_by_id(matched.id,false)

          cookies.permanent[:lactic_matched_picture] = matched.picture
        else
          matched.picture = cookies[:lactic_matched_picture]
        end

        @user.matched_user_model = matched
        @user.matched_user = matched.id
      end


      ### ONLY CALL PG WHEN LACK OF DETAILS ON COOKIE
      if !@user.name || !@user.email || @user.name.empty? || @user.email.empty? || (!cookies[:lactic_fb_id] && cookies[:lactic_picture].empty?)

        @user = (cookies[:lactic_mock_respond_id])? get_mock_user : get_current_session_user

        # puts "PICTURE FROM PG #{@user.picture} PICTURE ON LACTIC COOKIE #{cookies[:lactic_picture]}"

        if @user
        set_user_cookie(@user)
        # @user.uid = cookies[:lactic_fb_id]
        # @user.picture = cookies[:lactic_picture]
        @user.name = (@user && @user.name)? PostgresHelper.unescape_title_descriptions(@user.name) : ''

      end
      end
      # @user.matched = @user.matched_user && !@user.matched_user.empty?



    end
    @user
    # end



    # if @user.uid == '10153011850791938'
    #   puts "SEND NOTIFICATION #{DateTime.now}"
    #   email_notification(@user)

  #
  end



  def get_mock_user
    user = User.new
    user.id = 280906882262216
    user.uid = "280906882262216"
    user.name = "Tom Wongescu"
    user.email = "tomeongescu@gmail.com"
    user

  end


  def self.reset_current_user
    user = get_current_session_user
    set_user_cookie(user)
  end



  def skill_vote

    skill_vote = params[:skill]
    keywords_rated = (params[:keywords_rated])? JSON.parse(params[:keywords_rated]) : nil
    public_user = params[:public_user]

    user_info = UserInfo.new
    user_info.id = public_user
    user_info.keywords_rated = keywords_rated


    # puts "KEYWORDS RATED TRANSFER #{user_info.keywords_rated.inspect}"
    # puts "SKILL TRANSFER #{skill_vote}"
    # puts "PUBLIC USER TRANSFER #{public_user}"


    response = user_info.update_keywords_rated(cookies[:osm_respond_id],skill_vote,cookies[:lactic_name])


    if response
      user = User.new
      user.id = cookies[:osm_respond_id]
      user.uid = cookies[:lactic_fb_id]
      user.name = cookies[:lactic_name]
      new_skill_vote_notification(user,public_user,skill_vote)
    end

    # puts "RESPONSE FROM SKILL VOTE #{response.inspect}"


    respond_to do |format|
      format.html {redirect_to( public_profile_url({:id => params[:public_user]})) }
    end


  # end


end
end