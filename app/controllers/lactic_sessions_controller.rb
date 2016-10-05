require 'rest-client'
class LacticSessionsController < LacticSessionsCommonController

  before_action :global_sessions, only: [:index, :weekly_schedule, :show, :create]
  helper_method :lactic_google_calendar_redirect
  before_action :set_timezone
  before_action :notification_center, only: [:show, :index]


  def set_timezone
    @min = request.cookies["time_zone"].to_i
    Time.zone = ActiveSupport::TimeZone[-@min.minutes]
    @utc_offset = (Time.zone.parse(DateTime.now.to_s)).strftime("%:z")
    @zone_info = ActiveSupport::TimeZone.find_tzinfo(Time.zone.to_s.split(' ')[1])
  end
  def index
    puts "IN INDEX LACTIC SESSIONS CALLER #{caller[0].split("`").pop.gsub("'", "")} PARAMS #{params.inspect}"

    # puts "NEAREST LOCATIONS #{@nearest_locations.inspect}"
    @lactic_session = LacticSession.new
    @repeat_options =  [["Weekly",1],["Once",0]]

   # if cookies[:osm_respond_id] == '10153011850791938'
     # DOWNTOWN LA TESTING
     # 34.0407° N, 118.2468° W - Downtown LA
     # lat = 34.0407
     # longt = -118.2468
     #  34.0211° N, 118.3965° W - Culver city
     # lat = 34.0211
     # longt = -118.3965
     #  37.4419° N, 122.1430° W - Palo Alto
     # lat = 37.4419
     # longt = -122.1430


     # @nearest_locations = nearby_locations(lat , longt)
   # else
     if LacticLocation.valid_coordinates(cookies[:lactic_latitude] ,  cookies[:lactic_longitude])
       ### IN CASE THE USER'S LOCATION IS OFF - SHOW LAST LOCATION CHECK IN PLACES...
       lat = cookies[:lactic_latitude]
       longt = cookies[:lactic_longitude]
       @nearest_locations =  nearby_locations(lat , longt)

     end
  end


  def weekly_schedule
    puts "IN WEEKLY SESSIONS CALLER #{caller[0].split("`").pop.gsub("'", "")} PARAMS #{params.inspect}"
    @lactic_session = LacticSession.new
    @repeat_options =  [["Weekly",1],["Once",0]]
  end


  def edit_lactic_instagram_image
    # image = params[:lactic_image]
    image = (params[:lactic_session]["instagram_image"])? params[:lactic_session]["instagram_image"] : ''
    redirect_id = (params[:lactic_session]["redirect_id"])? params[:lactic_session]["redirect_id"] : ''



    puts "EDIT IMAGE #{image} WITH REDIRECT #{redirect_id}"
    if image && !image.empty? && redirect_id && !redirect_id.empty?
      current_session_user = get_current_user_from_cookie
      id = get_session_id_from_redirect(redirect_id)
      date = get_date_from_redirect(redirect_id)

      start_date_time = Time.zone.at(date.to_i / 1000).to_datetime

      @replica = SessionReplicasController.get_replica_by_origin(id,start_date_time)

      @lactic_session = LacticSession.new
      @lactic_session = (!@replica)?  @lactic_session.get_by_id(id,current_session_user.id.to_s) : @replica.lactic_session
      @lactic_session.instagram_image = image
      @lactic_session.start_date_time = start_date_time
      @lactic_session.end_date_time  = @lactic_session.start_date_time + @lactic_session.duration.minutes




      # puts "UPDATE IMAGE WITH #{@lactic_session.inspect}"
      # puts "UPDATE IMAGE  #{ @lactic_session.instagram_image}"
      image_update_result =  (!@replica) ? SessionReplicasController.new_replica_info( @lactic_session):
          SessionReplicasController.update_replica_info( @replica.id,@lactic_session);

      # if image_update_result && (@lactic_session.creator_fb_id != current_session_user.id.to_s)
      #   redirect_url = "#{@lactic_session.creator_fb_id}-#{id}-#{date}"
      #   new_vote_notification(current_session_user,@lactic_session.creator_fb_id, @lactic_session,redirect_url)
      # end

      update_session(current_session_user.uid,@lactic_session, redirect_id)



    end

    respond_to do |format|
      format.html {redirect_to( lactic_session_url({:id => redirect_id})) }
    end

  end


  def show
    @current_user_id = cookies[:osm_respond_id]
    puts "IN SHOW SESSIONS CALLER #{caller[0].split("`").pop.gsub("'", "")} PARAMS #{params.inspect}"
    @id = params[:id]

    @fb_invite_sent = session[:fb_invite_sent]
    session[:fb_invite_sent] = false

    @date_redirect = get_date_from_redirect(params[:id])
    @invited_callback = params[:invited]
    @lactic_session = (@lactic_sessions_hash && @lactic_sessions_hash[@id])? @lactic_sessions_hash[@id]:nil

    if (!@lactic_session)
      puts "HAVENT FOUND ON THE HASH!!!!!! FETCHINH FROM DB AGAIN..."
      @lactic_session = fetch_by_redirect_id @id, cookies[:osm_respond_id]
    else
      puts "IN SHOE SESSION CREATOR ID #{ @lactic_session.creator_id}  ==  current user ?? #{@current_user_id}"
    end

    replica_model = SessionReplica.new
    @replica = replica_model.get_by_origin(@lactic_session.id,Time.zone.parse(@lactic_session.start_date_time.to_s))
    @lactic_session.lactic_from_replica_session(@replica)
    @invited = Array.new

    @lactic_session.invitees.each do |invite_record|
      invite_record.each do |invitee_id,inviter_id|
        @invited << invitee_id
      end
    end


    @session_creator = @lactic_session.creator_fb_id
    lactic_location_setting
    @lactic_session.redirect_id =  params[:id]

    social_sharing_setting(params)


    if  session[:instagram_access_token]
      # puts "SESSION INSTAGRAM ACCESS #{session[:instagram_access_token]}"
      inst_lactic = instagram_lactic_pic
      @lactic_instagram_images=  inst_lactic[:lactic_instagram_images]
      # puts "SESSION INSTAGRAM LACTIC IMAGES #{@lactic_instagram_images.inspect}"

    else


    end

    @lactic_session.redirect_id = "#{@lactic_session.creator_id}-#{@lactic_session.id}-#{(@lactic_session.start_date_time.to_f * 1000).to_i}"
    # puts "LACTIC SESSION IMAGE #{@lactic_session.instagram_image}"

  end

  def lactic_location_setting
    location = LacticLocation.new
    location.id = @lactic_session.location_id
    location.origin = @lactic_session.location_origin
    location.location_url
    @session_location_url = location.url
    @session_location_website = location.website

  end
  def social_sharing_setting(params)
    ##### GOOGLE CALENDAR INTEGRATE
    if params[:google_access_token]
      ::GOOGLE_CALENDAR_CLIENT.login_with_refresh_token(params[:google_access_token])
      # puts "CALL FOR CALENDAR GOOGLE"
      lactic_to_google(@lactic_session)
    end

    #### ICAL INTEGRATE
    if params[:ical]
      ical_event = IcalendarClientController.event_to_ical(@lactic_session)
      if ical_event
        respond_to do |format|
          format.ics do
            response.headers['Content-Disposition'] = "attachment; filename=\"#{@lactic_session.title}.ics\""
            render text: ical_event, content_type: 'text/calendar',  filename: "#{@lactic_session.title}.ics"
          end
          format.html
          format.json  { render :json => @lactic_session }
        end
      else
        if params[:facebook_invite]
          respond_to do |format|
            format.html  {render FacebooksController.app_invite(cookies[:osm_respond_id],"https://warm-citadel-1598.herokuapp.com/lactic_sessions/#{@lactic_session.redirect_id}.html" )}
          end

        else
          respond_to do |format|
            format.html  # show.html.erb
            format.json  { render :json => @lactic_session }
          end

        end

      end

    end
  end



  def fb_invite

    session[:fb_invite_sent] = true
    respond_to do |format|
      format.html {redirect_to :back, :params => params[:url_params]}
    end


  end


  def fetch_by_redirect_id (redirect_id,uid)

    session = @lactic_sessions_hash["invite-#{redirect_id}"]
    if !session
      session = @lactic_sessions_hash["friend-#{redirect_id}"]

      if !session
        array_params = redirect_id.split("-")
        # puts "ARRAY PARAMS 0 === #{array_params[0]}"
        id  = (array_params[0] ==  'friend'|| (array_params[0] == 'invite') )? array_params[2].to_i : array_params[1].to_i
        start_time = (array_params[0] == 'friend' || (array_params[0] == 'invite'))? array_params[3] : array_params[2]
        session = LacticSession.new

        # puts "START TIME #{start_time} ID #{id}"
        session = session.get_by_id(id, uid)
        session.start_date_time = Time.at(start_time.to_i / 1000).to_datetime

        session.end_date_time ||=  session.start_date_time + session.duration.minute
      end
    end

    session
  end


  def new
    puts "IN NEW SESSIONS CALLER #{caller[0].split("`").pop.gsub("'", "")}"
    @lactic_session = LacticSession.new
    @repeat_options =  [["Weekly",0],["Once",1]]
  end


  def edit
  end


  def create
    schedule_session
  end


  def update
    respond_to do |format|
      if @lactic_session.update(lactic_session_params)
        format.html { redirect_to @lactic_session}
        format.json { render :show, status: :ok, location: @lactic_session }
      else
        format.html { render :edit }
        format.json { render json: @lactic_session.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy

  end




  def delete_lactic_session

    current_user = get_current_user_from_cookie
    # lactic_id = params[:id].split('-')[1]
    lactic_id = get_session_id_from_redirect(params[:id])
    lactic_delete_date = params[:delete_date]
    @lactic_sessions_hash = get_global_var(current_user.uid)[:hash_sessions]



    lactic_session_delete = (@lactic_sessions_hash && @lactic_sessions_hash[params[:id]] && @lactic_sessions_hash[params[:id]].id ==lactic_id) ?@lactic_sessions_hash[params[:id]] : LacticSession.new

    lactic_session_delete.id = lactic_id
    lactic_session_delete.date_deleted = lactic_delete_date

    lactic_session_delete.creator_id ||= cookies[:osm_respond_id]

    # result = lactic_session_delete.delete_session
    result = true
    if result
      invitees_redirect_id =  "invite-#{params[:id]}.html"

      # puts "UPDATE FETCHED DELETE ..."
      update_fetched_delete(params[:id],lactic_session_delete,current_user.matched_user)

      update_deleted(current_user.uid,params[:id],lactic_session_delete)

      if  lactic_session_delete.creator_id == current_user.uid &&  lactic_session_delete.invitees && !lactic_session_delete.invitees.empty?


        lactic_session_delete.invitees.each do |invitee_hash|
          # {"10153011850791938"=>133303790438201}
          invitee = invitee_hash.keys.first.to_i
          # puts "INVITEES DELETE NOTIFY #{invitee.inspect}"
          ### DB update

          lactic_session_delete.update_invitee_fetch_delete(invitees_redirect_id,invitee)
          ## Update global lactic sessions session variables

          update_deleted(invitee.to_s,invitees_redirect_id,lactic_session_delete)

          ### Send notification
          delete_session_notification(current_user,invitee,lactic_session_delete)

        end
      end

    end
    redirect_to lactics_path


  end






  def update_fetched_delete(hash_id,lactic_session_delete,match_id=nil)

    lactic_session_delete.update_fetch_delete(hash_id)
    if match_id
      lactic_session_delete.update_matched_fetch_delete(hash_id,match_id)
    end
    # update_deleted(uid,hash_id,lactic_session_delete)

  end




  def schedule_session
    @lactic_session = LacticSession.new

    respond_to do |format|

      @lactic_session.set_from_schedule_view(params[:lactic_session],cookies[:osm_respond_id],cookies[:osm_respond_id].to_i)


      if @lactic_session.valid_for_new_save

      result_session = @lactic_session.save_new_session


      if result_session

        @lactic_session = result_session.clone
        #
        matched_uid = @current_user.matched && cookies[:lactic_matched_id] ? cookies[:lactic_matched_id] : nil
        #
        @lactic_session.update_sessions_fetched(@user_lactic_sessions,@current_user.id.to_s,false,matched_uid)
        add_session(cookies[:osm_respond_id],@lactic_session)
        format.html  { redirect_to(lactics_path) }
        format.json  { render :json => @lactic_session,
                              :status => :created, :location => @lactic_session }
      else
        puts "SERVER SAVE Error!!!!!"

        format.html  { redirect_to(lactics_path,
                                     :notice => "Please check if you filled all the information needed for creating this LActic") }
        #
      end
      else
        puts "UN VALID LACTIC FOR SAVE"


        format.html  { redirect_to(lactics_path,
                                   :notice => "Please check if you filled all the information needed for creating this LActic") }
      end
    end
  end

  def show_public
    puts "IN SHOW PUBLIC SESSIONS CALLER #{caller[0].split("`").pop.gsub("'", "")} PARAMS #{params.inspect}"
    # set_timezone
    @id = params[:id]
    array_params = params[:id].split("-")
    @fb_invite_sent = session[:fb_invite_sent]
    @invited_callback = params[:invited]
    @current_user_uid = cookies['osm_respond_id']
    @date_redirect = get_date_from_redirect(params[:id])

    invite = array_params[0].eql? 'invite'
    creator = ((array_params[0].eql? 'friend') || invite )? array_params[1] : array_params[0]
    id  = ((array_params[0].eql? 'friend') || invite )? array_params[2] : array_params[1]
    id = (invite)? 'friend-'+id : id
    start_date  = (array_params[0].eql? 'friend' || invite)? array_params[3].to_f : array_params[2].to_f

    replica_model = SessionReplica.new



    puts "ID FROM SHOW PUBLIC #{id}"
    # id =  id.gsub('friend-','').gsub('invite-','')

    if creator == cookies[:osm_respond_id]
      # user_lactic_session = LacticSession.new
      redirect = params[:id].gsub('friend-','').gsub('invite-','').gsub('id=','')
      # user_lactic_session = @lactic_sessions_hash[redirect]

      # puts "TAKEN PUBLIC FROM HASH!!!!!! :) #{redirect}"
      # if user_lactic_session && user_lactic_session.id
        redirect_to :controller=>'lactic_sessions', :action => 'show', :id => redirect

        # redirect_to  lactic_sessions_path(:id => redirect)
      # end


    else

    @replica = replica_model.get_by_origin(id.gsub('friend-','').gsub('invite-','').gsub('id=',''),Time.zone.parse(Time.at(start_date / 1000).to_datetime.to_s))


    @lactic_session = LacticSession.new



      # @lactic_session =  (@replica)? @replica.lactic_session : @lactic_session.get_by_id(id,cookies[:osm_respond_id])


    @lactic_session = (@replica)? @replica.lactic_session : @lactic_session.get_by_id(id,cookies[:osm_respond_id])

    if @replica
      @lactic_session.lactic_from_replica_session(@replica)
    else
      @lactic_session.public_lactic_no_replica(start_date)
    end

    @invited = Array.new

    if @lactic_session.invitees
    @lactic_session.invitees.each do |invite_record|
      invite_record.each do |invitee_id,inviter_id|
        @invited << invitee_id
      end
    end
    end

    @session_creator = creator
    lactic_location_setting

    @lactic_session.redirect_id =  params[:id]

    social_sharing_setting(params)

    respond_to do |format|
      format.html   #show.html.erb
      format.json  { render :json => @lactic_session }
    end
  end
  end

  def self.matched_in_between(day1,day2, user,matched_user_uid)
    lactic_model = LacticSession.new
    # LacticSession.user_sessions_fetch(matched_user.uid,day1,day2)
    lactic_model.user_sessions_fetch(matched_user_uid,day1,day2)
  end


  def invite
    current_session_user = get_current_user_from_cookie

    id = (params[:lactic_session][:id])
    date = (params[:lactic_session][:start_time])

    invitees = (params[:lactic_session]["view_invitees"] && !params[:lactic_session]["view_invitees"].empty?)? JSON.parse(params[:lactic_session]["view_invitees"]) : Array.new

    start_date_time = Time.at(date.to_i / 1000).to_datetime

    @replica = SessionReplicasController.get_replica_by_origin(id,start_date_time.utc)

    @lactic_session = LacticSession.new

    @lactic_session = (!@replica)?  @lactic_session.get_by_id(id,current_session_user.id.to_s) : @replica.lactic_session

    @lactic_session.start_date_time = Time.zone.parse(start_date_time.to_s)
    @lactic_session.end_date_time  = @lactic_session.start_date_time + @lactic_session.duration.minutes
    # invitees.delete(@lactic_session.creator_fb_id)

    new_replica = @replica.nil?
    matched_uid = current_session_user.matched && cookies[:lactic_matched_id]? cookies[:lactic_matched_id] : nil



    invitees_hash = (@lactic_session.invitees && !@lactic_session.invitees.empty? && !@lactic_session.invitees[0].empty?)? Hash[@lactic_session.invitees.map(&:values).map(&:flatten)] : Hash.new

      @replica =  SessionReplicasController.invite(current_session_user, @lactic_session,invitees, new_replica,invitees_hash)
    redirect_id = (@lactic_session.creator_fb_id == current_session_user.id.to_s)?current_session_user.id.to_s : (@lactic_session.creator_fb_id == matched_uid)? "friend-#{matched_uid}" : "invite-#{@lactic_session.creator_fb_id}"

     @lactic_session.invite_session = true
      invitees.each do |invitee|
        ## check if invitee wasn't already invited to this session...
        if invitee && !invitees_hash[invitee] && invitee != @lactic_session.creator_fb_id
          result = @lactic_session.invite_to_session(current_session_user,invitee,matched_uid)
          if result
            new_invite_notification(current_session_user,invitee,@lactic_session)


            update_invite(invitee,@lactic_session,redirect_id)

          end

        end
      end


    redirect_id_url = "#{redirect_id}-#{id}-#{date}"

    update_session(current_session_user.uid,@lactic_session,redirect_id)


    respond_to do |format|
      if @lactic_session.creator_fb_id == current_session_user.uid
        format.html {redirect_to( lactic_session_url({:id => redirect_id_url, :invited => true})) }

      else

        format.html {redirect_to( show_public_url({:id => redirect_id_url, :invited => true})) }
      end
    end

    # respond_to do |format|
    #   format.html {redirect_to( lactic_session_url({:id => redirect_id_url, :invited => true})) }
    # end

  end




  def remove_invite
    current_session_user = get_current_user_from_cookie
    id = params[:id].split('-')[0].to_i
    date = params[:id].split('-')[1]

    start_date_time = Time.zone.at(date.to_i / 1000).to_datetime

    @replica = SessionReplicasController.get_replica_by_origin(id,start_date_time)
    @lactic_session = LacticSession.new
    @lactic_session = (!@replica)?  @lactic_session.get_by_id(id,current_session_user.id.to_s) : @replica.lactic_session

    @lactic_session.start_date_time = start_date_time
    @lactic_session.end_date_time  = @lactic_session.start_date_time + @lactic_session.duration.minutes

    matched_uid = current_session_user.matched && cookies[:lactic_matched_id] ? cookies[:lactic_matched_id] : nil
    lactic_uid = (@lactic_session.creator_fb_id == current_session_user.id.to_s)? @lactic_session.creator_fb_id : (@lactic_session.creator_fb_id == matched_uid)? "friend-#{@lactic_session.creator_fb_id}" : "invite-#{@lactic_session.creator_fb_id}"
    redirect_id ="#{lactic_uid}-#{@lactic_session.id}-#{(@lactic_session.start_date_time.to_f * 1000).to_i}"

    result = @lactic_session.remove_from_invite(cookies[:osm_respond_id])

    respond_to do |format|
      if result
        format.html {redirect_to( lactics_path ) }
      else
        format.html {redirect_to( lactic_session_url({:id => redirect_id})) }
      end
    end
  end



  def get_session_id_from_redirect (id_params)
     id_array = id_params.split('-')
    ((id_array[0].eql? 'invite') || (id_array[0].eql? 'friend')) ? id_array[2].to_i : id_array[1].to_i
  end

  def get_creator_id_from_redirect (id_params)
     id_array = id_params.split('-')
    ((id_array[0].eql? 'invite') || (id_array[0].eql? 'friend')) ? id_array[1] : id_array[0]
     end
  def get_date_from_redirect (id_params)
     id_array = id_params.split('-')
    ((id_array[0].eql? 'invite') || (id_array[0].eql? 'friend')) ? id_array[3].to_i : id_array[2].to_i
  end

  def vote_on
    current_session_user = get_current_user_from_cookie
    id = get_session_id_from_redirect(params[:id])
    date = get_date_from_redirect(params[:id])



    start_date_time = Time.zone.at(date.to_i / 1000).to_datetime

    @replica = SessionReplicasController.get_replica_by_origin(id,start_date_time)

    @lactic_session = LacticSession.new
    @lactic_session = (!@replica)?  @lactic_session.get_by_id(id,current_session_user.id.to_s) : @replica.lactic_session

    @lactic_session.start_date_time = start_date_time
    @lactic_session.end_date_time  = @lactic_session.start_date_time + @lactic_session.duration.minutes



    new_vote = (!@replica || !@replica.votes || @replica.votes.empty?)? true :false
    votes = (!@replica || !@replica.votes || @replica.votes.empty?)? nil: @replica.votes
    vote_result =  SessionReplicasController.vote(current_session_user.id.to_s,current_session_user.name, @lactic_session,new_vote,votes)

    if vote_result && (@lactic_session.creator_fb_id != current_session_user.id.to_s)
      redirect_url = "#{@lactic_session.creator_fb_id}-#{id}-#{date}"
      new_vote_notification(current_session_user,@lactic_session.creator_fb_id, @lactic_session,redirect_url)
    end

    update_session(current_session_user.uid,@lactic_session, params[:id])

    respond_to do |format|
      if @lactic_session.creator_fb_id == current_session_user.uid
        format.html {redirect_to( lactic_session_url({:id => params[:id]})) }

      else

        format.html {redirect_to( show_public_url({:id => params[:id]})) }
      end
    end


  end
  def comment_on
    puts "IN COMMENT CALLER #{caller[0].split("`").pop.gsub("'", "")} PARAMS #{params.inspect}"
    set_timezone
    current_session_user = get_current_user_from_cookie

    id = (params[:lactic_session][:id])
    date = (params[:lactic_session][:start_time])

    comment_text = (params[:lactic_session]["comment"])? params[:lactic_session]["comment"] : ''


    start_date_time = Time.at(date.to_i / 1000).to_datetime

    @replica = SessionReplicasController.get_replica_by_origin(id,start_date_time.utc)
    @lactic_session = LacticSession.new
    @lactic_session = (!@replica)?  @lactic_session.get_by_id(id,current_session_user.id.to_s) : @replica.lactic_session
    @lactic_session.start_date_time = Time.zone.parse(start_date_time.to_s)
    @lactic_session.end_date_time  = @lactic_session.start_date_time + @lactic_session.duration.minutes

    new_replica = @replica.nil?
    comment_result =  SessionReplicasController.comment(current_session_user, @lactic_session,comment_text, new_replica)
    matched_uid = current_session_user.matched && cookies[:lactic_matched_id] ? cookies[:lactic_matched_id] : nil
    redirect_id = (@lactic_session.creator_fb_id == current_session_user.id.to_s)?current_session_user.id.to_s : (@lactic_session.creator_fb_id == matched_uid)? "friend-#{matched_uid}" : "invite-#{@lactic_session.creator_fb_id}"

    if comment_result && (@lactic_session.creator_fb_id != current_session_user.id.to_s)
      redirect_id_url = "#{@lactic_session.creator_fb_id}-#{id}-#{date}"
      new_comment_notification(current_session_user,@lactic_session.creator_fb_id, @lactic_session,redirect_id_url)
   else
    redirect_id_url = "#{redirect_id}-#{id}-#{date}"
   end
    update_session(current_session_user.uid,@lactic_session, redirect_id_url)

    respond_to do |format|
      if @lactic_session.creator_fb_id == current_session_user.uid
        format.html {redirect_to( lactic_session_url({:id => redirect_id_url})) }

      else

        format.html {redirect_to( show_public_url({:id => redirect_id_url})) }
      end
    end

    # respond_to do |format|
    #   format.html {redirect_to( lactic_session_url({:id => redirect_id_url})) }
    # end

  end






  def set_locations

    cookies[:lactic_location] = (cookies[:lactic_location]=='on')? 'off' : 'on'

    # if cookies[:lactic_location] && cookies[:lactic_location] == 'on'

      # Thread.new{
    @nearest_locations = nearby_locations(cookies[:lactic_latitude],cookies[:lactic_longitude])
      # }
    respond_to do |format|
      # format.html {redirect_to profile_path }
      format.html {redirect_to :back, :params => params[:url_params] }
    end
  end



  private


  def global_sessions

      puts "IN SHARON GLOBAL SESSIONS CALLER #{caller[0].split("`").pop.gsub("'", "")} PARAMS #{params.inspect}"
      @auth_instagram = !session[:instagram_access_token] || session[:instagram_access_token].empty?
      @current_user = get_current_user_from_cookie
      @current_user_id = cookies[:osm_respond_id]
      matched_user_uid = (@current_user.matched)? @current_user.matched_user : ''

      set_timezone
      month_from_calendar = (params[:month_view_date])? params[:month_view_date].to_i : DateTime.now.month
      month = (params[:month_view_date])? params[:month_view_date].to_i : (params[:start])? Time.at(params[:start].to_i).month.to_i  : DateTime.now.month.to_i
      year = (params[:year_view_date])? params[:year_view_date].to_i : DateTime.now.year

      if month == DateTime.now.month && params[:id]
        begin
          id = params[:id].gsub('friend-','').gsub('invite-','').gsub('id=','')
          start = Time.at((id.split('-')[2].to_i/1000))
          month = start.month.to_i
          year = start.year
        rescue
        end
      end

      @lactic_sessions = get_global_var(@current_user.uid)[:sessions]
      @lactic_sessions_hash = get_global_var(@current_user.uid)[:hash_sessions]
      @fetched_month = get_global_var(@current_user.uid)[:fetched_month]
      @user_lactic_sessions = get_global_var(@current_user.uid)[:user_lactic_sessions]
      @current_fetched_sessions_ids = get_global_var(@current_user.uid)[:current_fetched_sessions_ids]

      # puts "FROM SHARON GLOBAL SESSION LENGTH #{@lactic_sessions.length}"

      if (@lactic_sessions && !@lactic_sessions.empty? && month_from_calendar == @fetched_month)
        puts "SHARON QUICKER !!!!"
      else
        ### SESSION USER RUN OUT NEED TO FETCH SESSIONS AGAIN...
        init_global_sessions(params)

        @lactic_sessions = get_global_var(@current_user.uid)[:sessions]
        @lactic_sessions_hash = get_global_var(@current_user.uid)[:hash_sessions]
        @fetched_month = get_global_var(@current_user.uid)[:fetched_month]
        @user_lactic_sessions = get_global_var(@current_user.uid)[:user_lactic_sessions]
        @current_fetched_sessions_ids = get_global_var(@current_user.uid)[:current_fetched_sessions_ids]
      end

    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def lactic_session_params
      params.require(:lactic_session).permit(:title, :description, :start_date_time, :end_date_time, :location, :location_id, :duration, :week_day, :creator_fb_id, :shared, :comment)
    end

end

# def global_sessions_2
#
#   puts "IN GLOBAL SESSIONS CALLER #{caller[0].split("`").pop.gsub("'", "")} PARAMS #{params.inspect}"
#   if cookies[:osm_respond_id] == '10153011850791938'
#
#     sharon_global_sessions(params)
#
#   else
#
#     lactic_session_model = LacticSession.new
#     @current_user_id = cookies[:osm_respond_id]
#     set_timezone
#
#
#     month_from_calendar = (params[:month_view_date])? params[:month_view_date].to_i : DateTime.now.month
#     month = (params[:month_view_date])? params[:month_view_date].to_i : (params[:start])? Time.at(params[:start].to_i).month.to_i  : DateTime.now.month.to_i
#     year = (params[:year_view_date])? params[:year_view_date].to_i : DateTime.now.year
#
#     if month == DateTime.now.month && params[:id]
#       begin
#         id = params[:id].gsub('friend-','').gsub('invite-','')
#         start = Time.at((id.split('-')[2].to_i/1000))
#         month = start.month.to_i
#         year = start.year
#       rescue
#       end
#     end
#     @current_user = get_current_user_from_cookie
#
#     matched_user_uid = (@current_user.matched)? @current_user.matched_user : ''
#
#     ### Fetch user sessions
#     # user_month_fetch = LacticSession.user_sessions_fetch(@current_user.uid,Time.parse("#{year}-#{month}-1").utc.to_datetime,Time.parse("#{year}-#{month}-1").utc.end_of_month)
#     user_month_fetch = lactic_session_model.user_sessions_fetch(@current_user.id.to_s,Time.parse("#{year}-#{month}-1").utc.to_datetime,Time.parse("#{year}-#{month}-1").utc.end_of_month)
#
#     # puts "FETCHING FOR MONTH #{month}"
#     # user_month_fetch[:sessions] .each do |lactic|
#     #   # puts "LACTIC FROM GLOBAL #{lactic.start_date_time}"
#     # end
#     ## Fetch sessions invites from other users
#     # user_contact_fetch = LacticSession.contact_sessions_fetch(@current_user.uid,Time.parse("#{year}-#{month}-1").utc.to_datetime,Time.parse("#{year}-#{month}-1").utc.end_of_month)
#     user_contact_fetch = lactic_session_model.contact_sessions_fetch(@current_user.id.to_s,Time.parse("#{year}-#{month}-1").utc.to_datetime,Time.parse("#{year}-#{month}-1").utc.end_of_month)
#
#
#
#     deleted_c = user_contact_fetch[:deleted_sessions] || Array.new
#     deleted_u = user_month_fetch[:deleted_sessions] || Array.new
#
#
#     deleted = deleted_c.concat(deleted_u)
#
#
#     @user_lactic_sessions ||= Array.new
#     @lactic_sessions ||= Array.new
#     @lactic_sessions_hash ||= Hash.new
#     @current_fetched_sessions_ids ||= Hash.new
#
#     if user_contact_fetch
#       user_queue = Queue.new
#       # deleted = user_contact_fetch[:deleted_sessions]
#       # puts "DELETED SESSIONS #{deleted.inspect}"
#       user_contact_fetch[:sessions].each do|session|
#         if session && !@current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"]
#           @current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] = true
#           ### Session is invitation only from a user that is not already matched to the current user
#           ### or a session that is the current user session already
#           session.invite_session = !(session.creator_fb_id == @current_user.id.to_s || ( @current_user.matched && session.creator_fb_id == matched_user_uid))
#
#           key = "#{session.creator_id}-#{session.id}-#{(session.start_date_time.to_f * 1000).to_i}"
#
#           if !(deleted.include? (key)) && !session.deleted
#             user_queue << session
#             @user_lactic_sessions << session
#             @lactic_sessions << session
#           end
#
#           # @lactic_sessions_queue << session
#         end
#       end
#       # puts "INVITES FOUND #{user_contact_fetch[:hash_sessions].inspect}"
#       # puts "DELETED ARRAY #{deleted.inspect}"
#       user_contact_fetch[:hash_sessions].each do |key,value|
#         key_for_deleted = key.gsub('invite-','').gsub('friend-','')
#         # puts "CHECK KEY FOR DELETE IN DELETED  ARRAY #{key_for_deleted}"
#         if !(deleted.include? (key) || (deleted.include? (key_for_deleted))) && !value.deleted
#           @lactic_sessions_hash[key] = value
#         else
#           # puts "INVITE DELETED VALUE #{value.inspect}"
#         end
#       end
#
#     end
#
#     if (month_from_calendar > DateTime.now.month || !user_month_fetch || user_month_fetch.empty? || !user_month_fetch[:sessions] || user_month_fetch[:sessions].empty? )
#       puts "FETCHING ASYNC ....."
#       fetch_sessions(month,year,@current_user.id.to_s,matched_user_uid)
#
#     else
#       # deleted = user_month_fetch[:deleted_sessions]
#       # puts "DELETED KEY???? #{key}"
#       # puts "DELETED SESSIONS #{deleted.inspect}"
#       user_month_fetch[:sessions].each do|session|
#
#         if session && !@current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"]
#           @current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] = true
#           ### Session is invitation only from a user that is not already matched to the current user
#           ### or a session that is the current user session already
#
#           key = "#{session.creator_id}-#{session.id}-#{(session.start_date_time.to_f * 1000).to_i}"
#
#
#
#           if (session.deleted)
#             # puts "DELETED SESSION #{session.title}"
#             # puts "DELETED SESSION date #{session.date_deleted}"
#           end
#
#           if !(deleted.include? (key)) && !session.deleted
#
#             # if !(deleted.any? { |s| s.include?(key) })
#             @user_lactic_sessions << session
#             @lactic_sessions << session
#           else
#             # puts "DELETED SESSIONS #{deleted } include #{key}"
#           end
#
#           # @lactic_sessions_queue << session
#         end
#
#       end
#
#
#
#       user_month_fetch[:hash_sessions].each do |key,value|
#         if !(deleted.include? (key)) && !value.deleted
#
#           @lactic_sessions_hash[key] = value
#         end
#
#         # puts "KEY INSERTRED #{key}"
#       end
#     end
#
#     @match_lactic_sessions = Array.new
#     @match_lactic_sessions_hash = Hash.new
#     if @current_user.matched
#       matched_sessions =(cookies[:lactic_matched_id])? LacticSessionsController.matched_in_between(Time.parse("#{year}-#{month}-1").utc.to_datetime,Time.parse("#{year}-#{month}-1").utc.end_of_month,@current_user,cookies[:lactic_matched_id]):Array.new
#       deleted = matched_sessions[:deleted_sessions]
#       if matched_sessions
#         matched_sessions[:sessions].each do|session|
#           if session && !@current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"]
#             @current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] = true
#             session.friend_session = session.creator_fb_id == matched_user_uid
#             key = "#{session.creator_id}-#{session.id}-#{(session.start_date_time.to_f * 1000).to_i}"
#
#             if (session.friend_session && !(deleted.include? (key))) && !session.deleted
#               @match_lactic_sessions << session
#               @lactic_sessions << session
#               # @lactic_sessions_queue << session
#             end
#           end
#         end
#         # puts "MATCHED SESSIONS  FOUND #{matched_sessions[:sessions].length}"
#
#         matched_sessions[:hash_sessions].each do |key,value|
#           key = "#{value.creator_id}-#{value.id}-#{(value.start_date_time.to_f * 1000).to_i}"
#
#           if !(deleted.include? (key)) && !value.deleted
#             id =  "friend-#{value.creator_fb_id}"
#             redirect_id ="#{id}-#{value.id}-#{(value.start_date_time.to_f * 1000).to_i}"
#             @lactic_sessions_hash[redirect_id] = value
#           end
#
#         end
#       end
#     end
#
#   end
#
#
# end


# def async_month_retrieved(user, month,year)
#
#   if month && year
#     Thread.new do
#       fetch_sessions(month,year,user.id.to_s,user.matched_user)
#     end
#   end
# end
#
#
# def save_last_retrieve_async(sessions,uid,month,year)
#
#   sdate_time = Time.parse("#{year}-#{month}-1").utc.to_datetime
#   # Thread.new do
#   matched_uid = @current_user.matched && cookies[:lactic_matched_id] ? cookies[:lactic_matched_id] : nil
#   if sessions && !sessions.empty?
#     lactic_model = LacticSession.new
#     lactic_model.save_last_fetch(sessions,uid,sdate_time,matched_uid,nil)
#   end
# end

# def fetch_sessions(month,year,uid,matched_user_uid)
#
#   backgroundOut = set_monthly_schedule(month,year,uid,matched_user_uid)
#   @user_lactic_sessions ||= []
#   @lactic_sessions_hash ||= Hash.new
#   if backgroundOut
#     backgroundOut[:sessions].each do|session|
#
#       if session && !@current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"]
#         @current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] = true
#         @user_lactic_sessions << session
#         @lactic_sessions << session
#       end
#     end
#     backgroundOut[:hash_sessions].each do |key,value|
#       @lactic_sessions_hash[key] = LacticSession.from_hash(value,cookies[:osm_respond_id])
#     end
#   end
#   save_last_retrieve_async(backgroundOut[:sessions],uid,month,year)
# end
#
# def set_monthly_schedule(start_month_date,start_year_date,current_user_uid,matched_user_uid)
#   lactic_sessions_hash = Hash.new
#   lactic_sessions_arr = []
#   sdate_time = Time.zone.parse("#{start_year_date}-#{start_month_date}-1").to_datetime
#
#   if (sdate_time)
#
#     (0..4).each do |i|
#       hash = set_weekly_schedule(sdate_time,current_user_uid,matched_user_uid)
#       hash[:hash_sessions].each do |key,value|
#         lactic_sessions_hash[key] = value
#       end
#       lactic_sessions_arr = lactic_sessions_arr+hash[:sessions]
#       sdate_time = DateTime.parse((Time.parse(sdate_time.to_s)+7.days).to_s)
#     end
#   end
#   {:hash_sessions => lactic_sessions_hash,:sessions =>  lactic_sessions_arr}
#
# end
# def set_weekly_schedule(start_week_date,current_user_uid,matched_user_uid)
#
#   lactic_session_model = LacticSession.new
#   lactic_sessions_hash = Hash.new
#   # lactic_sessions = (current_user_uid)? LacticSession.get_all_user_sessions(current_user_uid,start_week_date,current_user_uid) : []
#   lactic_sessions = (current_user_uid)? lactic_session_model.get_all_user_sessions(current_user_uid,start_week_date,current_user_uid) : []
#   final_lactic_sessions = Array.new
#
#   lactic_sessions.each do |lactic_session|
#     if lactic_session && lactic_session.start_date_time <= start_week_date+7.days && !lactic_session.deleted
#       if (lactic_session.end_date_time)
#         # && lactic_session.repeat == 0)
#       else
#         lactic_session.to_weekly_session(start_week_date)
#       end
#       lactic_session_hash = lactic_session.to_lactic_hash
#       final_lactic_sessions << lactic_session
#       lactic_session_hash = LacticSession.to_weekly_sessiosn_hash(lactic_session_hash,start_week_date)
#
#       id = (lactic_session.creator_fb_id==current_user_uid)? lactic_session.creator_fb_id : "friend-#{lactic_session.creator_fb_id}"
#       redirect_id ="#{id}-#{lactic_session.id}-#{(lactic_session.start_date_time.to_f * 1000).to_i}"
#
#       lactic_sessions_hash[redirect_id] = lactic_session_hash
#     end
#   end
#
#   {:hash_sessions => lactic_sessions_hash,:sessions =>  final_lactic_sessions}
#
# end