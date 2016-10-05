class NotificationsController < GoogleClientController
  # helper_method :notification_center
  # before_action :notification_center

  helper_method :presence_channel_users
  protect_from_forgery :except => [:auth, :mock_auth]
  def index
    # puts "SHOW NOTIFICATION USERS CONTROLLER METHOD CALLER #{caller[0].split("`").pop.gsub("'", "")} FOR UID == #{cookies[:osm_respond_id]}"

    if cookies[:osm_respond_id] && !cookies[:osm_respond_id].empty?
      notification = Notification.new
      notification.id = cookies[:osm_respond_id]

      @notifications_record = notification.get_notifications(cookies[:osm_respond_id].to_i)
    @notification = @notifications_record.queue
    end
  end

  # def notification_center
  #   @notifications_record = Notification.get_notifications(cookies[:osm_respond_id])
  #   @notifications = @notifications_record.queue
  #
  #   puts "NOTIFICATIONS controller #{@notifications.inspect}"
  #
  #   # @notification
  # end


  # def self.reset_notifications(notification_id)
  #   notification = Notification.new
  #   notification.id = notification_id
  #   notification.reset_notifications(notification_id)
  #
  #
  # end


  def reset_notifications

    puts "RESETING NOTIFICATIONS!"
    notification_id = cookies[:osm_respond_id].to_i
    if notification_id && notification_id!=0 &&  session[:invites_notifiactions] && session[:requests_notifiactions] && session[:timeline_notifiactions] &&
        session[:invites_notifiactions]+
        session[:requests_notifiactions] +
      session[:timeline_notifiactions]  != 0
        notification = Notification.new
        notification.id = notification_id
        notification.reset_notifications(notification_id)

        init_notifications

    end
    respond_to do |format|
      # format.html {redirect_to profile_path }
      format.html {redirect_to :back, :params => params[:url_params] }
    end



  end

  def set_all_notifications(uid)

    notification = Notification.new

    notification.id = uid.to_i
    # notification.get_notifications(uid) || notification
    notification.get_notifications(notification.id) || notification


    # session_notifications(notification)


  end

  def show

  end


  def delete_session_notification (notifier, to_id, session)


    puts "NOTIFICATION FOR DELETE #{notifier}"
    result = nil

    message = NotificationsHelper.get_message(notifier,NotificationsHelper::DELETE_SESSION,session)
    puts "NOTIFICATION FOR DELETE MESSAGE #{message} TO #{to_id}"


    notification = new_notify(to_id)


    lactic_uid = "invite-#{session.creator_fb_id}"
    # url = "/lactic_sessions/#{lactic_uid}-#{session.id}-#{(session.start_date_time.to_f * 1000).to_i}"
    url = "/public_profile?id=#{notifier.id}"
    result = (notification)? notification.new_notification(notifier,message,NotificationsHelper::INVITES, url) : nil


    ### Send notification alert....
    send_notification(to_id,"#{notifier.name} removed #{session.title} from LACtic calendar!",result,"invites")

    result
  end

  ### Save new notification record and send alert to the client invitee...
  def new_invite_notification (notifier, to_id, session)

    result = nil

    message = NotificationsHelper.get_message(notifier,NotificationsHelper::INVITES,session)

    notification = new_notify(to_id)


    lactic_uid = "invite-#{session.creator_fb_id}"
    url = "/lactic_sessions/#{lactic_uid}-#{session.id}-#{(session.start_date_time.to_f * 1000).to_i}"

    result = (notification)? notification.new_notification(notifier,message,NotificationsHelper::INVITES, url) : nil


    ### Send notification alert....
    send_notification(to_id,"New invite from #{notifier.name}",result,"invites")

    result
  end

  def lactic_match_request(requestor, responder_id)
    message = NotificationsHelper.get_message(requestor,NotificationsHelper::REQUESTS)

    # puts "MESSAGE NOTIFY #{message}"
    notification = new_notify(responder_id)
    requestor_url = "/public_profile?id=#{requestor.id}"

    result = (notification)? notification.new_notification(requestor,message,NotificationsHelper::REQUESTS, requestor_url) : nil

    # puts "RESULT #{result}"

    ### Send notification alert....
    # send_notification(to_id, "New vote on #{session.title} from #{notifier.name}")
    send_notification(responder_id, "New LActic request from #{requestor.name}",result,"requests")

    result
  end

  def lactic_match_resopnd(user_responder,requestor_id)
    message = NotificationsHelper.get_message(user_responder,NotificationsHelper::RESPOND)

    # puts "MESSAGE NOTIFY #{message}"
    notification = new_notify(requestor_id)
    user_url = "/public_profile?id=#{user_responder.id}"

    result = (notification)? notification.new_notification(user_responder,message,NotificationsHelper::REQUESTS, user_url) : nil

    # puts "RESULT #{result}"

    ### Send notification alert....
    # send_notification(to_id, "New vote on #{session.title} from #{notifier.name}")
    send_notification(requestor_id, "You and #{user_responder.name} are now LACticated!",result,"responds")

    result
  end


  def new_vote_notification (notifier, to_id, session, session_url)
    message = NotificationsHelper.get_message(notifier,NotificationsHelper::VOTE,session)

    notification = new_notify(to_id)
    url = "/lactic_sessions/#{session_url}"

    result = (notification)? notification.new_notification(notifier,message,NotificationsHelper::INVITES, url) : nil

    # puts "NOTIFICATION NEW VOTE RESULT #{result.inspect}"

    ### Send notification alert....
    # send_notification(to_id, "New vote on #{session.title} from #{notifier.name}")
    send_notification(to_id, "New vote on #{session.title} from #{notifier.name}",result,"")

    result
  end



  def new_skill_vote_notification (notifier, to_id, skill)
    message = NotificationsHelper.get_message(notifier,NotificationsHelper::SKILL_VOTE,skill)
    # puts "COMMENTING NOTIFICAION FROM NOTIFICATION  CONTROLLER #{message}"
    # url = "/lactic_sessions/#{session_url}"

    notification = new_notify(to_id)
    url = "/profile"
    result = (notification)? notification.new_notification(notifier,message,NotificationsHelper::USERS, url) : nil


    ### Send notification alert....
    send_notification(to_id, "A New vote on your '#{skill}' skill from #{notifier.name}",result,"")


    result
  end

  def new_comment_notification (notifier, to_id, session, session_url)
    message = NotificationsHelper.get_message(notifier,NotificationsHelper::COMMENT,session)

    url = "/lactic_sessions/#{session_url}"

    notification = new_notify(to_id)

    result = (notification)? notification.new_notification(notifier,message,NotificationsHelper::INVITES, url) : nil
    puts "COMMENTING NOTIFICAION FROM NOTIFICATION  CONTROLLER #{notification.inspect}"

    ### Send notification alert....
    send_notification(to_id, "New comment on #{session.title} from #{notifier.name}",result,"")

    result
  end


  def send_friends_new_join(notifier,to_all)
      to_all.each do|to|
        new_contact_join(notifier, to.id.to_s)
      end
  end
  def new_contact_join (notifier, to_id)
    message = NotificationsHelper.get_message(notifier,NotificationsHelper::JOIN)
    # puts "COMMENTING NOTIFICAION FROM NOTIFICATION  CONTROLLER #{message}"

    notification = new_notify(to_id)
    notifier_url = "/public_profile?id=#{notifier.id.to_s}"
    result = (notification)? notification.new_notification(notifier,message,NotificationsHelper::INVITES, notifier_url) : nil


    ### Send notification alert....
    send_notification(to_id,message,result,"")

    result

  end

  def new_notify(to_id)

    notification = nil
    if  to_id

      notification = Notification.new
      notification.id =  to_id.to_i
      notification = notification.get_notifications(notification.id) || notification
    end
    puts " NOTIFICAION FROM NOTIFICATION  CONTROLLER #{notification.inspect}"

    notification
  end

  def new

  end


  def edit
  end


  def create

  end


  def update

  end



  def send_notification(to_id, message, result, notify_type="")
    # puts "PUSH NOTIFICATION #{message} RESULT #{result.inspect}"
    if result
    Pusher["#{to_id}"].trigger('invite', {
                                           :greeting => message,
                                           :notify_type => notify_type
                                       })


    end
  end

  # def self.invite_notification(to_id, notifier)
  #
  #   Pusher["#{to_id}"].trigger('invite', {
  #                                          :greeting => "New invite from #{notifier.name}"
  #                                      })
  #   # Pusher["#{notifier.id}"].trigger('invite', {
  #   #                                        :greeting => "New invite from #{notifier.name}"
  #   #                                    })
  #
  # end


  ## Fetch new invites , updating badge & calendar(sessions retrieve)
  def fetch_notification

    # puts "FETCHING NEW INVITES!!!! #{caller[0].split("`").pop.gsub("'", "")}"


    # {"utf8"=>"✓", "authenticity_token"=>"FU/6NSDkbmDwrufw3WEAOkEtAbUr7Qn+ZV8C1wfdMDhwTRMrESt4daLxRjDq9oz1D0uvJFK9afX+OZqdrTFzVQ==",
    # "notification"=>{"invites"=>"true"},
    # "controller"=>"notifications",
    # "action"=>"fetch_invites"}
    # puts "FETCHING NEW notification PARAMS!!!! #{params.inspect}"


    notification_params = params["notification"]
    notification_types = notification_params["notification_type"].split(",")
    puts "NOTIFICATION TYPE #{notification_types.inspect}"


    notification_model = Notification.new

    notification_model.id =  cookies[:osm_respond_id]
    @notification_fetched = notification_model.get_notifications(cookies[:osm_respond_id])

    notification_types.each do |notification_type|
      case notification_type
        when NotificationsHelper::INVITES
          puts "NOTIFICATION TYPE #{notification_type}"
        when NotificationsHelper::REQUESTS
          # Thread.new {
            UsersController.reset_current_user
          # }
          puts "NOTIFICATION TYPE #{notification_type}"
        when NotificationsHelper::RESPOND
          # Thread.new {
            UsersController.reset_current_user
          # }
          puts "NOTIFICATION TYPE #{notification_type}"
          #### RESET THE USER COOKIE WITH MATCH
        else
          puts "NOTIFICATION TYPE #{notification_type}"

      end
    end



    # puts "FETCHING NEW INVITES!!!! #{@notification_fetched.inspect}"
    # @profile_notification = 6
    session_notifications(@notification_fetched)
    respond_to do |format|
      # format.html {redirect_to profile_path }
      format.html {redirect_to :back, :params => params[:url_params] }
    end
  end



  # Never trust parameters from the scary internet, only allow the white list through.
  def notifications_params
    params.require(:notification).permit(:requests, :invites, :users, :timeline, :notifier, :message, :queue)
  end



  def subscribe_to_keywords(keywords_about)
    keywords_about.each do |keyword|

      notification_model = Notification.new
      notification_model.id = cookies[:osm_respond_id]
      notification_model.subscribe_to_keyword(keyword,cookies[:osm_respond_id],{name: cookies[:lactic_name]})
    end

  end
  def presence_channel_users (name)
     presenceChannel = ::PUSHER[name]
     # puts "PRESENCE INSPECT #{presenceChannel.inspect}"
     # puts "ALL PRESENCE INSPECT #{::PUSHER.channels.inspect}"
    # users = presenceChannel.channel_users(name, {})[:users]
    users = presenceChannel.users

    # puts "USERS CHANNEL FOR CHANNLE #{name} == #{users.inspect}"
    # puts "INFO CHANNEL #{presenceChannel.info.inspect}"
    # puts "USERS 2 CHANNEL #{@client.channel_users(name, params)[:users].inspect}"
  end



  def mock_auth
    json_result = ::PUSHER[params[:channel_name]].authenticate(params[:socket_id],
                                                               {user_id: '1234567890',
                                                                user_info: {name: 'mock',
                                                                            email: 'mock@email.com'} # optional
                                                               })
    # response = ::PUSHER.authenticate(params[:channel_name], params[:socket_id], {
    #                                                         user_id: cookies[:osm_respond_id], # => required
    #                                                         user_info: { # => optional - for example
    #                                                                      name: cookies[:lactic_name],
    #                                                                      email: cookies[:email]
    #                                                         }
    #                                                     })
    # puts "AUTH RESULT #{json_result.inspect}"
    # render json: response

    # {:auth=>"5806b3cc65c341de1bcb:6ec7176691e935ea21ea8017aca4a5377ed3c325c2a4827b7d4440398c6839e1",
    # :channel_data=>"{\"user_id\":\"10153011850791938\",
    # \"user_info\":{\"name\":\"Sharon Nachum\",\"email\":\"sharonanachum@gmail.com\"}}"}

    render :json => json_result
  end


  def auth
    # puts "NOTIFICATION AUTH PARAMS #{params.inspect}"
    # puts "NOTIFICATION AUTH PARAMS for #{params[:channel_name].split('presence-')[1]}"


    if NotificationsHelper::PRESENCE_CHANNELS.include? (params[:channel_name].split('presence-')[1])

      json_result = ::PUSHER[params[:channel_name]].authenticate(params[:socket_id],
                                                                 {user_id: cookies[:osm_respond_id],
                                                                  user_info: {name: cookies[:lactic_name],
                                                                              email: cookies[:email]} # optional
                                                                 })
      # response = ::PUSHER.authenticate(params[:channel_name], params[:socket_id], {
      #                                                         user_id: cookies[:osm_respond_id], # => required
      #                                                         user_info: { # => optional - for example
      #                                                                      name: cookies[:lactic_name],
      #                                                                      email: cookies[:email]
      #                                                         }
      #                                                     })
      # puts "AUTH RESULT #{json_result.inspect}"
      # render json: response

      # {:auth=>"5806b3cc65c341de1bcb:6ec7176691e935ea21ea8017aca4a5377ed3c325c2a4827b7d4440398c6839e1",
      # :channel_data=>"{\"user_id\":\"10153011850791938\",
      # \"user_info\":{\"name\":\"Sharon Nachum\",\"email\":\"sharonanachum@gmail.com\"}}"}

    render :json => json_result


    end



    # if current_user
    # puts "NOTIFICATION AUTH PARAMS #{params.inspect}"
    #   response = Pusher.authenticate(params[:channel_name], params[:socket_id], {
    #                                                           user_id: cookies[:osm_respond_id], # => required
    #                                                           user_info: { # => optional - for example
    #                                                                        name: cookies[:lactic_name],
    #                                                                        email: cookies[:email]
    #
    #                                                           }
    #                                                       })
    #   respond_to do |format|
      #   # if @lactic_session.update(lactic_session_params)
      #     format.html { redirect_to search_path }
      #   #   format.json { render :show, status: :ok, location: @lactic_session }
      #   # else
      #   #   format.html { render :edit }
      #     format.json { render json: response }
      #   # end
      # end
      # render json: response
    # else
    #   render text: 'Forbidden', status: '403'
    # end
  end
  def curret_channel_users(channel_name)
    notification = Notification.new
    current_users = notification.curret_channel_users(channel_name)

    # puts "CURRENT SUBSCRIBERS #{current_users.inspect}"
    current_users
  end



  def email_new_features(to_user)
    Email.email_notification(to_user,'email_new_features').deliver

    end

  def email_lactic_partner(to_user)
    Email.email_notification(to_user,'email_new_features').deliver

  end

  def email_lactic_create(to_user)
    Email.email_notification(to_user,'email_lactic_create').deliver

  end


  def email_sharon(to_user)
    Email.email_notification(to_user,'email_sharon').deliver

  end

  def email_notification(to_user)
    puts "EMAIL NOTIFICATION #{DateTime.now}"
    # notification = Email.new

    notifications = Notification.new
    email_notifications = notifications.get_notifications(to_user.id)

    Email.email_notification(to_user,'email_notification_center',email_notifications).deliver
    # @notifications =
    # respond_to do |format|
    #   # format.html {redirect_to profile_path }
    #   format.html {redirect_to :back, :params => params[:url_params] }
    # end
  end
end

