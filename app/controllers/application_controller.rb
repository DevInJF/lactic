require 'rest-client'
class ApplicationController < ActionController::Base
  rescue_from Timeout::Error, with: :handle_timeout

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :check_logged_in
  helper_method :render_session
  helper_method :notification_alert
  helper_method :get_current_session_user
  helper_method :all_contacts
  helper_method :contacts
  helper_method :url_params, :osm_cookie
  helper_method :facebook_oauth_retrieve
  helper_method :session_notifications
  helper_method :notification_auth_endpoint
  helper_method :notification_mock_auth_endpoint
  # helper_method :sign_out_user
  # helper_method :search_friends
  # helper_method :set_facebook_friends
  # helper_method :osm_users_friends
  before_action :set_timezone, :profile_notification, :notification, :set_notifications
  # before_action :notification_center
  before_action :location_share
  before_action :current_user_cookie_id

  rescue_from Rack::Timeout::RequestTimeoutError,
              Rack::Timeout::RequestExpiryError,
              with: :handle_timeout


  include LacticLocationHelper
  # @nearest_locations_fetched
  def set_timezone


    @min = request.cookies["time_zone"].to_i
    Time.zone = ActiveSupport::TimeZone[-@min.minutes]
    @utc_offset = (Time.zone.parse(DateTime.now.to_s)).strftime("%:z")
    # puts "TIME ZONE #{Time.zone}"
    @zone_info = ActiveSupport::TimeZone.find_tzinfo(Time.zone.to_s.split(' ')[1])
    # puts "TIME NOW LOCAL  #{@zone_info.utc_to_local(Time.now)}"


    # @utc_offset = (@min > 0 )? (@utc_offset.gsub('-','+')) :(@utc_offset.gsub('+','-'))
  end


  def facebook_oauth_retrieve
    Koala::Facebook::OAuth.new(ENV["FACEBOOK_KEY"], ENV["FACEBOOK_SECRET"])
  end






  private
  def current_user
    user_model = User.new

    db_current_user ||= user_model.get_user_by_fbID(session[:user_id],true) if session[:user_id]

    # parse_current_user ||= ParseUser.get_osm_users_by_fbId(session[:user_id]) if session[:user_id]
    # User.from_parse(parse_current_user)
  end





  def get_current_user_from_cookie
    user = User.new
    user.id = cookies[:osm_respond_id].to_i
    user.google_id = cookies[:lactic_google_id]
    user.uid = cookies[:lactic_fb_id]
    user.name = cookies[:lactic_name]
    user.email = cookies[:lactic_email]
    user.matched_user = cookies[:lactic_matched_id]
    user.matched_picture = cookies[:lactic_matched_picture]
    user.matched = cookies[:lactic_matched]
    user.picture = cookies[:lactic_picture]
    user
  end

  def set_user_cookie(user)

    if user
    if cookies[:lactic_mock_respond_id]
      user.id = 280906882262216
      user.uid = "280906882262216"
      user.name = "Tom Wongescu"
      user.email = "tomeongescu@gmail.com"
    end



    cookies.permanent[:lactic_email] = user.email
    cookies.permanent[:lactic_picture] = (user.picture && !user.picture.empty?)? user.picture : "https://graph.facebook.com/#{user.uid}/picture?type=large"
    cookies.permanent[:email]= user.email
    cookies.permanent[:name]= user.name
    cookies.permanent[:lactic_name]= user.name
    cookies.permanent[:last_osm_respond_id]= user.id
    cookies.permanent[:osm_respond_id]= user.id
    cookies.permanent[:lactic_fb_id]= user.uid
    cookies.permanent[:lactic_google_id]= user.google_id
    cookies.permanent[:lactic_matched_id] = user.matched_user
    cookies.permanent[:lactic_matched]= user.matched
    cookies.permanent[:lactic_location] ||= 'off'
    cookies.permanent[:google_token] = user.google_token
    cookies.permanent[:google_access_token] = user.google_token


      puts "SET USER COOKIE #{user.inspect}"

  end
  end






  def set_matched_cookie(id, is_matched, picture=nil)
    cookies.permanent[:lactic_matched_id]= id
    cookies.permanent[:lactic_matched]= is_matched

    if picture
      cookies.permanent[:lactic_matched_picture]= picture
    end

  end


  def check_logged_in

    # "CHECK LOGGED IN #{cookies['osm_respond_id']}"
    # "CHECK LOGGED IN #{cookies['last_osm_respond_id']}"
    # "CHECK LOGGED IN #{cookies['osm_respond_id'] &&
    #     cookies['last_osm_respond_id'] &&
    #     (cookies['osm_respond_id'] ==  cookies['last_osm_respond_id'])}"
     cookies['osm_respond_id'] &&
         cookies['last_osm_respond_id'] &&
         (cookies['osm_respond_id'] ==  cookies['last_osm_respond_id'])
  end


  def get_current_session_user
    # puts "UID FETCHING FROM COOKIE #{cookies[:osm_respond_id]} CALLER #{caller[0].split("`").pop.gsub("'", "")}"
    id = cookies[:osm_respond_id].to_i

    user_model = User.new
    user_model.get_user_by_id(id,true)

  end

  def get_current_session_user_with_info
    id = cookies[:osm_respond_id].to_i

    user_model = User.new
    user_model.get_user_by_id(id,true)

  end


  def set_fb_contacts

    # current_session_user = get_current_session_user

    uid = (cookies[:lactic_fb_id])? cookies[:lactic_fb_id] : ''

    if uid && ! uid.empty?

      UsersController.set_fb_lactic_contacts(uid)

    else
      Array.new

    end
  end



  def all_contacts
    search_combined = []
    # current_session_user = get_current_session_user
    contacts_hash = UsersController.get_contacts(cookies[:osm_respond_id])


    if contacts_hash
      search_combined ||= (contacts_hash[:non_lactic].merge(contacts_hash[:lactic])).to_a
    end

    json_result = from_json_load(search_combined)
    # puts "JSON #{json_result.inspect}"



    all_contacts_json = UsersController.get_all_contacts(cookies[:lactic_email])
    all = (all_contacts_json)? JSON.parse(all_contacts_json) : Array.new


    # all = all.map { |o| Hash[o.each_pair.to_a] }.to_json
    # all_json = from_json_load ((contacts_hash[:all]))

    # puts "ALL #{all.inspect}"


    all.each do |user|
      # puts "USER TO ADD #{user.inspect}"

      json_result << user.to_json
    end
    # json_result = json_result.concat(all)
    # puts "JSON AFTER #{json_result.inspect}"

    json_result = json_result.uniq { |h| h['name'] }
    # puts "JSON AFTER FROM ALL CONTACTS #{json_result.inspect}"

    json_result

  end



  def contacts(lactic)
    search_combined = []
    # current_session_user = get_current_session_user
    contacts_hash = UsersController.get_contacts(cookies[:osm_respond_id])

    if contacts_hash
      search_combined = (lactic)? (contacts_hash[:lactic]) :(contacts_hash[:non_lactic])
    end

    json_result = from_json_load(search_combined)



    all_contacts_json = UsersController.get_all_contacts(cookies[:lactic_email])
    all = (all_contacts_json)? JSON.parse(all_contacts_json) : Array.new

    # all = (contacts_hash[:all] && lactic)? JSON.parse(contacts_hash[:all]) : Array.new


    # all = all.map { |o| Hash[o.each_pair.to_a] }.to_json
    # all_json = from_json_load ((contacts_hash[:all]))




    all.each do |user|

      json_result << user
    end


    json_result = json_result.uniq { |h| h['name'] }
    # puts "JSON AFTER FROM CONTACTS #{json_result.inspect}"

    json_result


    # json_result




  end




  def from_json_load(search_combined)

    first_parse =  search_combined.to_s.gsub('\\\\"', '"')

    first_parse = first_parse.gsub('\\"', '"')
    first_parse = first_parse.gsub('\\\"', '"')
    first_parse = first_parse.gsub('\\\"', '"')

    json_result = (search_combined.to_s.gsub('\"', '"')).to_json
    if (!search_combined ||  search_combined.empty? || search_combined[0]=="{}"|| search_combined[0]=="{[]}" )
      json_result = [{}]
    else
        json_result = JSON.parse(search_combined[0].gsub('{"[', '[').gsub(']"}', ']').gsub('\"', '"'))
        json_result
    end

    json_result



  end


  def set_access_control_headers
    headers['Access-Control-Allow-Origin'] = 'https://warm-citadel-1598.herokuapp.com/Remove'
  end



  def current_user_cookie_id
    @current_user_cookie_id = cookies[:osm_respond_id]
  end
  def profile_notification
    @profile_notification = 5
  end



  def notification_alert
    # puts "IN NOTIFICATOIN ALERT"
    @profile_notification = 6
  end


  def notification
    @notification = Notification.new
  end


  def url_params
    params[:id]
  end


  def osm_cookie
    # puts "OSM COOKIE ===== #{cookies[:osm_id]}"
    cookies[:osm_id]
  end


  def set_notifications(notification = nil)
    @invites_notifiactions = (notification) ? notification.invites : session[:invites_notifiactions] || 0
    @requests_notifiactions = (notification) ?notification.requests : session[:requests_notifiactions] || 0
    @timeline_notifiactions = (notification) ?notification.timeline : session[:timeline_notifiactions] || 0

    @total =  @invites_notifiactions +@requests_notifiactions + @timeline_notifiactions

  end


  def init_notifications


      @invites_notifiactions = 0
      @requests_notifiactions = 0
      @timeline_notifiactions = 0
      @total = 0
      session[:invites_notifiactions]  = 0
      session[:requests_notifiactions] =  0
      session[:timeline_notifiactions]  = 0





  end


  def session_notifications(notification)
    session[:invites_notifiactions] =  (notification) ? notification.invites : 0
    session[:requests_notifiactions] =  (notification) ? notification.requests : 0
    session[:timeline_notifiactions] =  (notification) ? notification.timeline : 0
  end

  def notification_center


    id  = cookies[:osm_respond_id].to_i

    if  cookies[:osm_respond_id] != 'undefined' && id && id!=0
     begin
       id = Integer(cookies[:osm_respond_id])
      notification = Notification.new
      @notifications_record = notification.get_notifications(cookies[:osm_respond_id])
      @notifications = (@notifications_record)? @notifications_record.queue : Array.new
     rescue
     end
    end

    # puts "NOTIFICATIONS controller #{@notifications.inspect}"

    # @notification
  end


  def location_radius

  end

  def location_share

    @location_share = (!cookies[:lactic_location] || cookies[:lactic_location] == 'off') ? 'off' : 'on'
    @location_opp_share = (!cookies[:lactic_location] || cookies[:lactic_location] == 'off') ? 'on' : 'off'
    cookies[:lactic_location] = @location_share


    # @nearest_locations_fetched ||= Array.new

    # @nearest_locations ||= Array.new
    # puts "LOCATION SHARE COOKIE #{@location_share}"



  end

  # def last_lactic_locations(nearest_locations)
  #   global = LacticGlobal.instance
  #   global.last_lactic_locations = nearest_locations
  #
  #
  #   # @nearest_locations = nearest_locations
  # end

  # def get_last_locations_shared
  #   global = LacticGlobal.instance
  #   @nearest_locations = global.last_lactic_locations
  #   # @nearest_locations
  # end
  def notification_mock_auth_endpoint
    notifications_mock_auth_path
  end


  def notification_auth_endpoint
    notifications_auth_path
  end
  private
  def handle_timeout(exception)
    # If there is no accepted format declared by controller

    puts "ERROR TIME OUT #{exception.inspect}"

    ActiveRecord::Base.connection.reset!

    # Render error page
    # respond_with_error_status(503)


    respond_to do |format|
      format.html do
        render file: Rails.root.join("public/503.html"),
               status: 503, layout: nil
      end
      format.all  { head 503 }
    end
  end


  protected
  def handle_timeout
    # render "shared/timeout"
    puts "HANDLE TIME OUT "
    respond_to do |format|
      # format.html {redirect_to profile_path }
      format.html {redirect_to :back, :params => params[:url_params] }
    end
  end
end
