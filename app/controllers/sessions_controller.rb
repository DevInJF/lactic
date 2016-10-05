class SessionsController < NotificationsController
  helper_method :render_login
  helper_method :send_sharon_email
  # layout 'owl', only: [:about_lactic]
  # layout 'animate', only: [:about_lactic]
  # layout 'cardio', only: [:about_lactic]

  def render_login
    render :partial => "sessions/login_form"
    # redirect_to url_for(:controller => :sessions, :action => :index)

  end
  def index
    puts "IN INDEX SESSIONS CALLER #{caller[0].split("`").pop.gsub("'", "")} PARAMS #{params.inspect}"

    @facebook_login_callback =  (params[:facebook_sign_in])? true : false

    # puts "INSPECT SESSION INDEX PARAMS #{params.inspect}"
    puts "COOKIE FROM SESSION INDEX #{cookies.inspect}"
    puts "INSPECT CURRENT COOKIE OSM_ID #{cookies[:osm_id]}"
    puts "INSPECT CURRENT COOKIE OSM RESPOND ID #{cookies[:osm_respond_id]}"
    # puts "INSPECT CURRENT COOKIE TIME ZONE  #{cookies[:time_zone]}"
    #
    # cookies.delete('osm_id')
    # cookies.delete('osm_respond_id')
    # cookies.delete('current_access_token')
    # cookies.delete('current_access_token_expires_in')
    #
    @cookie = cookies[:lactic_mock_respond_id]? cookies[:lactic_mock_respond_id] : cookies[:osm_id]
    @mock = cookies[:lactic_mock_respond_id]
    # puts "COOKIE SESSION #{cookies.inspect}"
    @exchangeUrl = "https://graph.facebook.com/oauth/access_token?grant_type=fb_exchange_token&fb_exchange_token=#{cookies['accessToken']}&client_id=#{FACEBOOK_CONFIG['app_id']}&client_secret=#{FACEBOOK_CONFIG['secret']}"
    @access_token_cookie = cookies['current_access_token']
    @access_token_cookie_expires = cookies['current_access_token_expires_in']
    # puts "COOKIE SESSION #{cookies.inspect}"
    # puts "CURRENT EXPIRE #{@access_token_cookie_expires}"
    if (@cookie && !@cookie.empty? && @cookie.to_i !=0 && cookies[:osm_respond_id]&& !cookies[:osm_respond_id].empty?)
      ### found last signed FB id
      ### check if user id is OSM user
      id  = cookies[:osm_respond_id].to_i
      if  cookies[:osm_respond_id] != 'undefined' && id && id!=0
        user_model = User.new

        @current_user = user_model.get_user_by_id(id,true)


        puts "CURRENT USER FROM POSTGRES #{@current_user.inspect}"

        if (@current_user)

          set_user_cookie( @current_user)
          cookies.permanent[:osm_respond_id] = @current_user.id
          cookies.permanent[:lactic_fb_id] = @current_user.uid
          cookies.delete('osm_response')
          ## Setting session notifications
          notification = set_all_notifications(cookies[:osm_respond_id])
          session_notifications(notification)

          redirect_to url_for(:controller => :users, :action => :index) and return

        else
          ### LogIn with FB
          puts "Logged in with facebook but not on POSTGRES!"
          if @cookie && @cookie.to_i != 0
            # set_user_cookie( @current_user)
            cookies.permanent[:osm_respond_id] = @cookie
            cookies.permanent[:lactic_fb_id] = @cookie
            cookies.delete('osm_response')
            ## Setting session notifications
            # notification = set_all_notifications(cookies[:osm_respond_id])
            # session_notifications(notification)

            redirect_to url_for(:controller => :users, :action => :index) and return

          end


        end

      else
        puts "Logged in with facebook but not on POSTGRES and OSM_RESPOND ID UNDEFINED!"
        # set_user_cookie( @current_user)
        if @cookie && @cookie.to_i != 0
          cookies.permanent[:osm_respond_id] = @cookie
          cookies.permanent[:lactic_fb_id] = @cookie
          cookies.delete('osm_response')
          ## Setting session notifications
          # notification = set_all_notifications(cookies[:osm_respond_id])
          # session_notifications(notification)

          redirect_to url_for(:controller => :users, :action => :index) and return

        end


      end


    else
      ## CHECK IF SIGNING WITH MOCK USER
      puts "CHECK IF SIGNING WITH MOCK USER"
      if cookies[:lactic_mock_respond_id] && !(cookies[:lactic_mock_respond_id].empty?)
        @current_user = User.get_mock_user

        set_user_cookie( @current_user)

        # if  cookies[:osm_respond_id] && cookies[:lactic_mock_respond_id]==cookies[:osm_respond_id]
        cookies.permanent[:osm_respond_id] = cookies[:lactic_mock_respond_id]
        cookies.permanent[:lactic_fb_id] = cookies[:lactic_mock_respond_id]
        cookies.delete('osm_response')
          ## Setting session notifications
          notification = set_all_notifications(cookies[:osm_respond_id])
          session_notifications(notification)

          redirect_to url_for(:controller => :users, :action => :index) and return

        # else
        #   puts "REDIRECTING MOCK TO ROOT..."
          # redirect_to root_path

        # end


      else
        @facebook_login_callback =  (params[:facebook_sign_in] && params[:facebook_sign_in] == true)? true : false

        if @facebook_login_callback
          redirect_to about_path(facebook_sign_in: true)
        else
          puts "PARAMS FROM INDEX SESSIONS  LACTIC #{params.inspect}"
          redirect_to about_path
        end


      end


    end
  end



  def lactic_tour
    @current_user = User.get_mock_user
    cookies[:lactic_mock_respond_id] = @current_user.uid
    set_user_cookie( @current_user)

    # if  cookies[:osm_respond_id] && cookies[:lactic_mock_respond_id]==cookies[:osm_respond_id]
    cookies.permanent[:osm_respond_id] = cookies[:lactic_mock_respond_id]
    cookies.permanent[:lactic_fb_id] = cookies[:lactic_mock_respond_id]
    cookies.delete('osm_response')
    ## Setting session notifications
    notification = set_all_notifications(cookies[:osm_respond_id])
    session_notifications(notification)

    redirect_to url_for(:controller => :users, :action => :index) and return

  end

  def send_sharon_email
    if cookies[:osm_respond_id] == '10153011850791938'
      # puts "SEND NOTIFICATION #{DateTime.now}"
      user_to = User.new
      # user_to.email = params[:send_to_email]
      user_to.email = 'lacticinc@gmail.com'
      user_to.name = 'sharon'
      user_to.id = '10153011850791938'

      if user_to.email && user_to.name
        # email_notification(user_to)
        email_sharon(user_to)
        # email_lactic_create(user_to)
        # email_lactic_partner(user_to)
      end
      #
      # user_to.email = params[:send_to_email]
      # puts "SEND EMAIL NOTOIFIACTION TO #{user_to.inspect}"
    end

  end


  def about_lactic
    # puts "PARAMS FROM ABOUT LACTIC #{params.inspect}"
    @cookie = cookies[:osm_id]
    # puts "PARAMS FROM ABOUT LACTIC COOKIE OSM  #{@cookie.inspect}"
    @exchangeUrl = "https://graph.facebook.com/oauth/access_token?grant_type=fb_exchange_token&fb_exchange_token=#{cookies['accessToken']}&client_id=#{FACEBOOK_CONFIG['app_id']}&client_secret=#{FACEBOOK_CONFIG['secret']}"
    @access_token_cookie = cookies['current_access_token']
    @access_token_cookie_expires = cookies['current_access_token_expires_in']

    # puts "PARAMS FROM ABOUT LACTIC COOKIE ACCESS TOKEN  #{@access_token_cookie.inspect}"

    @about = true


    @gmail_sign_in = (params[:gmail_sign_in])?  user_from_google_session : nil
    @gmail_signed = (@gmail_sign_in && @gmail_sign_in.id)


    @facebook_login_callback =  (params[:facebook_sign_in] && params[:facebook_sign_in] == true)? true : false

    id  = cookies[:osm_respond_id].to_i

    if !@cookie || @cookie.to_i == 0 && ( cookies[:osm_respond_id] == 'undefined' || !id && id==0)


      # @access_token_cookie = cookies['current_access_token']
      # @access_token_cookie_expires = cookies['current_access_token_expires_in']


      puts "NOT FB AND NEW USER"

      # puts "COOKIE UID FOR NEW #{@cookie}"

    else
      cookies.permanent[:osm_respond_id] = @cookie
      cookies.permanent[:lactic_fb_id] = @cookie
      cookies.permanent[:current_access_token] = @access_token_cookie
      cookies.permanent[:current_access_token_expires_in] = @access_token_cookie_expires
      cookies.delete('osm_response')
      puts " NEW USER LOGIN !!!!"


      @user = (@gmail_sign_in && @gmail_sign_in.id)? @gmail_sign_in : get_current_session_user

      if (!@user || !@user.uid || @user.uid.empty?)
        # && @facebook_login_callbackm == true
        ##
        puts "COOKIE UID FOR NEW FACEBOOK REDIRECT #{@cookie} AND NEW USER "

        redirect_to url_for(:controller => :users, :action => :lactic_in, :params => params) and return

      else
        puts "COOKIE UID FOR NEW FACEBOOK REDIRECT #{@cookie} AND USER === #{@user.inspect}"



      end


      # redirect_to url_for(:controller => :users, :action => :index, :params => params) and return


    end


    # if @facebook_login_callback
    #   redirect_to about_path
    # end


  end

  def user_from_google_session
    @gmail_sign_in = User.new
    @gmail_sign_in.id = session[:google_user_id]
    @gmail_sign_in.google_id = session[:google_user_id]
    @gmail_sign_in.name =   session[:google_user_name]
    @gmail_sign_in.email = session[:google_user_email]
    @gmail_sign_in.picture = session[:google_user_picture]
    @gmail_sign_in.google_token = session[:google_user_token]

    puts "USER FROM SESSION GOOGLE #{@gmail_sign_in.inspect}"

    @gmail_sign_in
  end



  def sign_out
    if cookies[:osm_respond_id]
      cookies.delete('osm_id')
      cookies.delete('osm_response')
      cookies.delete('osm_name')
      cookies.delete('osm_respond_id')
      cookies.delete('lactic_mock_respond_id')
      cookies.delete('current_access_token')
      cookies.delete('current_access_token_expires_in')
      cookies.delete('lactic_name')
      cookies.delete('lactic_email')
      cookies.delete('lactic_picture')
      cookies.delete('lactic_matched_id')
      cookies.delete('lactic_matched_picture')
      cookies.delete('lactic_matched')
      cookies.delete('lactic_location')
      cookies.delete('google_token')
      # cookies['osm_id'] = ''
      respond_to do |format|
        format.html { redirect_to sessions_url}
      end
    end
  end




end
