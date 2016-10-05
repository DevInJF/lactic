class LacticSessionsCommonController < LacticLocationsController


  $users_common_sessions ||= Hash.new
  # before_action :init_global_sessions


  def set_timezone
    @min = request.cookies["time_zone"].to_i
    Time.zone = ActiveSupport::TimeZone[-@min.minutes]
    @utc_offset = (Time.zone.parse(DateTime.now.to_s)).strftime("%:z")
    @zone_info = ActiveSupport::TimeZone.find_tzinfo(Time.zone.to_s.split(' ')[1])
  end






  def get_all_between(day1,day2,user, requestor_user)
    set_timezone
    month1 = day1.month.to_i  || DateTime.now.month.to_i
    month2 = day2.month.to_i || DateTime.now.month.to_i
    year = day1.year


    lactic_session_model = LacticSession.new
    # @current_user = get_current_session_user
    @current_user = get_current_user_from_cookie

    matched_user_uid = (@current_user.matched)? @current_user.matched_user : ''


    # matched_user_uid = (user.matched && user.matched_user_model)? user.matched_user_model.uid : nil



    ### Fetch user sessions
    # user_month_fetch = lactic_session_model.user_sessions_fetch(user.uid,Time.parse("#{year}-#{month1}-1").utc.to_datetime,Time.parse("#{year}-#{month2}-1").utc.end_of_month)
    user_month_fetch = lactic_session_model.user_sessions_fetch(user.id.to_s,Time.parse("#{year}-#{month1}-1").utc.to_datetime,Time.parse("#{year}-#{month2}-1").utc.end_of_month)

    ## Fetch sessions invites from other users
    # user_contact_fetch = (requestor_user.uid == user.uid || requestor_user.matched_user == user.uid)? LacticSession.contact_sessions_fetch(user.uid,Time.parse("#{year}-#{month1}-1").utc.to_datetime,Time.parse("#{year}-#{month2}-1").utc.end_of_month):nil
    user_contact_fetch = (requestor_user.id.to_s == user.id.to_s || requestor_user.matched_user == user.id.to_s)? lactic_session_model.contact_sessions_fetch(user.id.to_s,Time.parse("#{year}-#{month1}-1").utc.to_datetime,Time.parse("#{year}-#{month2}-1").utc.end_of_month):nil

    @user_lactic_sessions ||= Array.new
    @lactic_sessions ||= Array.new
    @lactic_sessions_hash ||= Hash.new
    @current_fetched_sessions_ids ||= Hash.new
    deleted_c = (user_contact_fetch)? user_contact_fetch[:deleted_sessions] || Array.new : Array.new
    deleted_u = user_month_fetch[:deleted_sessions] || Array.new


    @deleted = deleted_c.concat(deleted_u)

    if user_contact_fetch

      user_contact_fetch[:sessions].each do|session|
        if session && !@current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] && session.start_date_time >= day1 && session.start_date_time <= day2
          @current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] = true
          ### Session is invitation only from a user that is not already matched to the current user
          ### or a session that is the current user session already
          key = "#{session.creator_id}-#{session.id}-#{(session.start_date_time.to_f * 1000).to_i}"

          if !(@deleted.include? (key)) && !session.deleted
            session.invite_session = !(session.creator_fb_id == @current_user.id.to_s || ( @current_user.matched && session.creator_fb_id == matched_user_uid))
            @user_lactic_sessions << session
            @lactic_sessions << session
          end


        end
      end

      user_contact_fetch[:hash_sessions].each do |key,value|
        key_for_deleted = key.gsub('invite-','').gsub('friend-','')
        if !(@deleted.include? (key) || (@deleted.include? (key_for_deleted))) && !value.deleted
          @lactic_sessions_hash[key] = value
        end
      end

    end


    user_month_fetch[:sessions].each do|session|

      if session && !@current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] && session.start_date_time >= day1 && session.start_date_time <= day2
        @current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] = true
        ### Session is invitation only from a user that is not already matched to the current user
        ### or a session that is the current user session already
        key = "#{session.creator_id}-#{session.id}-#{(session.start_date_time.to_f * 1000).to_i}"
        # puts "DELETED SESSIONS === #{deleted.inspect}"
        # puts "DELETED SESSIONS key === #{key}"
        if !(@deleted.include? (key)) && !session.deleted

            @user_lactic_sessions << session
            @lactic_sessions << session

        end
      end

    end

    user_month_fetch[:hash_sessions].each do |key,value|
      if !(@deleted.include? (key)) && !value.deleted
        @lactic_sessions_hash[key] = value
      end
    end


    @match_lactic_sessions = Array.new
    @match_lactic_sessions_hash = Hash.new
    if user.matched && user.matched_user_model && user.matched_user_model.id
      matched_sessions = matched_in_between(Time.parse("#{year}-#{month1}-1").utc.to_datetime,Time.parse("#{year}-#{month2}-1").utc.end_of_month,user.matched_user_model.id.to_s)
      if matched_sessions
        matched_sessions[:sessions].each do|session|
          if session && !@current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] && session.start_date_time >= day1 && session.start_date_time <= day2
            @current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] = true
            session.friend_session = session.creator_fb_id == matched_user_uid
            key = "#{session.creator_id}-#{session.id}-#{(session.start_date_time.to_f * 1000).to_i}"

            if (session.friend_session && !(matched_sessions[:deleted_sessions].include? (key))) && !session.deleted
              @match_lactic_sessions << session
              @lactic_sessions << session

            end
          end
        end
        matched_sessions[:hash_sessions].each do |key,value|
          key = "#{value.creator_id}-#{value.id}-#{(value.start_date_time.to_f * 1000).to_i}"

          if !(matched_sessions[:deleted_sessions].include? (key)) && !value.deleted
          id =  "friend-#{value.creator_fb_id}"
          redirect_id ="#{id}-#{value.id}-#{(value.start_date_time.to_f * 1000).to_i}"
          @lactic_sessions_hash[redirect_id] = value
        end
        end
      end
    end
    {:hash_sessions => @lactic_sessions_hash,:sessions =>  @lactic_sessions}
  end


  def matched_in_between(day1,day2,matched_user_uid)

    lactic_session = LacticSession.new

    # LacticSession.user_sessions_fetch(matched_user_uid,day1,day2)
    lactic_session.user_sessions_fetch(matched_user_uid,day1,day2)
  end






  ### initialize after user connect 'users/check_expired_and_update' before getting the profile
  ### page
  def init_global_sessions(params=Hash.new)

    puts "IN INIT GLOBAL SESSIONS CALLER #{caller[0].split("`").pop.gsub("'", "")} PARAMS #{params.inspect}"
    @user_lactic_sessions ||= Array.new
    @lactic_sessions ||= Array.new
    @week_lactic_sessions ||= Hash.new
    @lactic_sessions_hash ||= Hash.new
    @current_fetched_sessions_ids ||= Hash.new
    @deleted ||= Array.new

    @fetched_month ||= DateTime.now.month.to_i

    lactic_session_model = LacticSession.new
    @current_user = get_current_user_from_cookie
    matched_user_uid = (@current_user.matched)? @current_user.matched_user : ''
    set_timezone


    month_from_calendar = (params && params[:month_view_date])? params[:month_view_date].to_i : DateTime.now.month
    month = DateTime.now.month.to_i
    year =  DateTime.now.year



    ### Fetch user sessions
    user_month_fetch = lactic_session_model.user_sessions_fetch(@current_user.id.to_s,Time.parse("#{year}-#{month}-1").utc.to_datetime,Time.parse("#{year}-#{month}-1").utc.end_of_month)
    user_contact_fetch = lactic_session_model.contact_sessions_fetch(@current_user.id.to_s,Time.parse("#{year}-#{month}-1").utc.to_datetime,Time.parse("#{year}-#{month}-1").utc.end_of_month)

    deleted_c = user_contact_fetch[:deleted_sessions] || Array.new
    deleted_u = user_month_fetch[:deleted_sessions] || Array.new
    @deleted = deleted_c.concat(deleted_u)



    if user_contact_fetch
      user_queue = Queue.new

      user_contact_fetch[:sessions].each do|session|
        if session && !@current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"]
          @current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] = true
          ### Session is invitation only from a user that is not already matched to the current user
          ### or a session that is the current user session already
          session.invite_session = !(session.creator_fb_id == @current_user.id.to_s || ( @current_user.matched && session.creator_fb_id == matched_user_uid))

          key = "#{session.creator_id}-#{session.id}-#{(session.start_date_time.to_f * 1000).to_i}"

          if !(@deleted.include? (key)) && !session.deleted
            user_queue << session
            @user_lactic_sessions << session
            @lactic_sessions << session

            day = calc_day(session.start_date_time)

            if day >= 0 && day <= 6
              if  !@week_lactic_sessions[day]
                @week_lactic_sessions[day] = Array.new
              end
              @week_lactic_sessions[day] <<  session
            end
          end
        end
      end
      user_contact_fetch[:hash_sessions].each do |key,value|
        key_for_deleted = key.gsub('invite-','').gsub('friend-','')
        # puts "CHECK KEY FOR DELETE IN DELETED  ARRAY #{key_for_deleted}"
        if !(@deleted.include? (key) || (@deleted.include? (key_for_deleted))) && !value.deleted
          @lactic_sessions_hash[key] = value
        else
        end
      end

    end

    if (month_from_calendar > DateTime.now.month || !user_month_fetch || user_month_fetch.empty? || !user_month_fetch[:sessions] || user_month_fetch[:sessions].empty? )
      puts "FETCHING ASYNC ....."
      Thread.new{
        fetch_month_sessions(month,year,@current_user.id.to_s,matched_user_uid)
      }

    else

      user_month_fetch[:sessions].each do|session|

        if session && !@current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"]
          @current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] = true
          ### Session is invitation only from a user that is not already matched to the current user
          ### or a session that is the current user session already

          key = "#{session.creator_id}-#{session.id}-#{(session.start_date_time.to_f * 1000).to_i}"

          if !(@deleted.include? (key)) && !session.deleted
            @user_lactic_sessions << session
            @lactic_sessions << session
            day = calc_day(session.start_date_time)

            if day >= 0 && day <= 6
              if  !@week_lactic_sessions[day]
                @week_lactic_sessions[day] = Array.new
              end
              @week_lactic_sessions[day] <<  session
            end
          else
            # puts "DELETED SESSIONS #{deleted } include #{key}"
          end
        end

      end



      user_month_fetch[:hash_sessions].each do |key,value|
        if !(@deleted.include? (key)) && !value.deleted
          @lactic_sessions_hash[key] = value
        end
      end
    end

    @match_lactic_sessions = Array.new
    @match_lactic_sessions_hash = Hash.new
    if @current_user.matched
      matched_sessions =(cookies[:lactic_matched_id])? matched_in_between(Time.parse("#{year}-#{month}-1").utc.to_datetime,Time.parse("#{year}-#{month}-1").utc.end_of_month,cookies[:lactic_matched_id]):Array.new

      (@deleted << matched_sessions[:deleted_sessions]).flatten!


      if matched_sessions
        matched_sessions[:sessions].each do|session|
          if session && !@current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"]
            @current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] = true
            session.friend_session = session.creator_fb_id == matched_user_uid
            key = "#{session.creator_id}-#{session.id}-#{(session.start_date_time.to_f * 1000).to_i}"

            if (session.friend_session && !(@deleted.include? (key))) && !session.deleted
              @match_lactic_sessions << session
              @lactic_sessions << session
              # @lactic_sessions_queue << session
              day = calc_day(session.start_date_time)
              if day >= 0 && day <= 6
                if  !@week_lactic_sessions[day]
                  @week_lactic_sessions[day] = Array.new
                end
                @week_lactic_sessions[day] <<  session
              end
            end
          end
        end
        # puts "MATCHED SESSIONS  FOUND #{matched_sessions[:sessions].length}"

        matched_sessions[:hash_sessions].each do |key,value|
          key = "#{value.creator_id}-#{value.id}-#{(value.start_date_time.to_f * 1000).to_i}"

          if !(@deleted.include? (key)) && !value.deleted
            id =  "friend-#{value.creator_fb_id}"
            redirect_id ="#{id}-#{value.id}-#{(value.start_date_time.to_f * 1000).to_i}"
            @lactic_sessions_hash[redirect_id] = value
          end

        end
      end
    end


    $users_common_sessions[@current_user.uid] =
        {:hash_sessions => @lactic_sessions_hash,:sessions =>  @lactic_sessions,
         :weekly_sessions => @week_lactic_sessions,
         :deleted => @deleted,
         :fetched_month => @fetched_month,
         :current_fetched_sessions_ids => @current_fetched_sessions_ids,
         :user_lactic_sessions => @user_lactic_sessions}
    $users_common_sessions[@current_user.uid]

  end

  def add_instagram_token

  end

  def calc_day(start_date_time)
    now = DateTime.now
    dif_hour = DateTime.new(now.year, now.month, now.day,start_date_time.hour,start_date_time.min,0)
    day = ((start_date_time - dif_hour.beginning_of_day)/ 86400).floor
    # puts "DATE FOR WEEKLY DAY FROM #{day} FROM #{start_date_time}"
    day
  end



  def get_global_var(uid)
    # {:hash_sessions => @@lactic_sessions_hash,
    # :sessions =>  @@lactic_sessions,
    # :weekly_sessions => @@week_lactic_sessions,
    # :deleted => @@deleted, :fetched_month => @@fetched_month,
    # :current_fetched_sessions_ids => @@current_fetched_sessions_ids,
    # :user_lactic_sessions => @@user_lactic_sessions}
    $users_common_sessions[uid]? $users_common_sessions[uid] : init_global_sessions
  end

  def update_deleted(uid,deleted_id,lactic_session_delete)
    if uid && $users_common_sessions[uid]

      @deleted = $users_common_sessions[uid][:deleted]
      @deleted << deleted_id
      @lactic_sessions =  $users_common_sessions[uid][:sessions]
      @user_lactic_sessions =  $users_common_sessions[uid][:user_lactic_sessions]
      @week_lactic_sessions =  $users_common_sessions[uid][:weekly_sessions]
      @lactic_sessions_hash =  $users_common_sessions[uid][:hash_sessions]
      @current_fetched_sessions_ids =  $users_common_sessions[uid][:current_fetched_sessions_ids]


      # puts "LACTIC SESSIONS BEFORE LENGTH #{@lactic_sessions.length}"
      @lactic_sessions.delete_if {|session| session.id == lactic_session_delete.id }
      # puts "LACTIC SESSIONS AFTER LENGTH #{@lactic_sessions.length}"
      @user_lactic_sessions.delete_if {|session| session.id == lactic_session_delete.id }

      @current_fetched_sessions_ids.delete_if {|session_id| session_id == deleted_id }

      day = calc_day(lactic_session_delete.start_date_time)
      # puts "WEEKLY OF #{uid} BEFORE #{@week_lactic_sessions[day].inspect}"

      @week_lactic_sessions[day].delete_if {|session| session &&  session.id == lactic_session_delete.id  }

      # puts "WEEKLY OF #{uid} AFTER #{@week_lactic_sessions[day].inspect}"
      @lactic_sessions_hash.delete(deleted_id)


      ### TO DO ::: UPDATE DELETE FOR ALL OTHER INVITEES/MATCH....!



    end



  end


  def update_session(uid,lactic_session, hash_id)
    if hash_id && !hash_id.empty? && uid && $users_common_sessions[uid]
      @lactic_sessions_hash =  $users_common_sessions[uid][:hash_sessions]

      puts "UPADTE HASH ID #{hash_id}"
      @lactic_sessions_hash[hash_id] = lactic_session

      ### NOT UPDATING THE SESSION ITSELF IN THE SESSIONS
      ### Updating a session occures when a change has been made to the session
      ### such as adding a vote, comment, invites - all these updates are not seen
      ## on the monthly scheduler and fecth by the full-calendar regulary
      ## the actual change is to the replica . which is always shown from the hash.
      ## adding a session is to 'add_session' and delete also hs its own method
    end
  end

  def update_invite(uid,lactic_session,hash_id)
    if uid && $users_common_sessions[uid]

      @lactic_sessions_hash =  $users_common_sessions[uid][:hash_sessions]
      @lactic_sessions =  $users_common_sessions[uid][:sessions]
      @week_lactic_sessions =  $users_common_sessions[uid][:weekly_sessions]


      @lactic_sessions_hash[hash_id] = lactic_session
      @lactic_sessions << lactic_session
      day = calc_day(lactic_session.start_date_time)


      if (!@week_lactic_sessions[day])
        @week_lactic_sessions[day] = Array.new
      end
      @week_lactic_sessions[day] << lactic_session

    end
  end

  def add_session(uid,lactic_session, hash_id='')
    if uid && $users_common_sessions[uid]

      @lactic_sessions =  $users_common_sessions[uid][:sessions]
      @user_lactic_sessions =  $users_common_sessions[uid][:user_lactic_sessions]
      @week_lactic_sessions =  $users_common_sessions[uid][:weekly_sessions]
      @lactic_sessions_hash =  $users_common_sessions[uid][:hash_sessions]



      @lactic_sessions << lactic_session


    id = (lactic_session.creator_fb_id==cookies[:osm_respond_id])? lactic_session.creator_fb_id : "friend-#{lactic_session.creator_fb_id}"
    redirect_id ="#{id}-#{lactic_session.id}-#{(lactic_session.start_date_time.to_f * 1000).to_i}"

    hash_id = (hash_id && !hash_id.empty?)? hash_id : redirect_id
    @lactic_sessions_hash[redirect_id] = lactic_session


    if (lactic_session.creator_fb_id==cookies[:osm_respond_id])
      @user_lactic_sessions << lactic_session
    end


    # puts "DATE FOR WEEKLY DAY FROM #{day} FROM #{session.start_date_time}"
    day  = calc_day(lactic_session.start_date_time)


    if day >= 0 && day <= 6
      if  !@week_lactic_sessions[day]
        if  !@week_lactic_sessions[day]
          @week_lactic_sessions[day] = Array.new
        end
        @week_lactic_sessions[day] <<  lactic_session
      end
    end



  end
  end

  def fetch_month_sessions(month,year,uid,matched_user_uid)

    backgroundOut = set_monthly_sessions_schedule(month,year,uid,matched_user_uid)
    @user_lactic_sessions ||= []
    @lactic_sessions_hash ||= Hash.new
    @fetched_month = month

    if backgroundOut
      backgroundOut[:sessions].each do|session|

        if session && !@current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"]
          @current_fetched_sessions_ids["#{session.creator_fb_id}=#{session.start_date_time}"] = true
          @user_lactic_sessions << session
          @lactic_sessions << session


          day  = calc_day(session.start_date_time)

          if day >= 0 && day <= 6
            if  !@week_lactic_sessions[day]
              if  !@week_lactic_sessions[day]
                @week_lactic_sessions[day] = Array.new
              end
              @week_lactic_sessions[day] <<  session
            end
          end
        end
        backgroundOut[:hash_sessions].each do |key,value|
          @lactic_sessions_hash[key] = LacticSession.from_hash(value,cookies[:osm_respond_id])
        end
      end
      save_month_retrieve_async(backgroundOut[:sessions],uid,month,year)
    end
  end

  def save_month_retrieve_async(sessions,uid,month,year)

    sdate_time = Time.parse("#{year}-#{month}-1").utc.to_datetime
    # Thread.new do
    matched_uid = @current_user.matched && cookies[:lactic_matched_id] ? cookies[:lactic_matched_id] : nil
    if sessions && !sessions.empty?
      lactic_model = LacticSession.new
      lactic_model.save_last_fetch(sessions,uid,sdate_time,matched_uid,nil)


      set_globals_from_user_session(uid)

      # $users_common_sessions[uid][:hash_sessions] = @lactic_sessions_hash
      # $users_common_sessions[uid][:sessions] = @lactic_sessions
      # $users_common_sessions[uid][:weekly_sessions] = @weekly_sessions
      # $users_common_sessions[uid][:current_fetched_sessions_ids] = @current_fetched_sessions_ids
      # $users_common_sessions[uid][:user_lactic_sessions] = @user_lactic_sessions
      # # { => @,
      # :sessions =>  @@lactic_sessions,
      # :weekly_sessions => @@weekly_sessions,
      # :deleted => @@deleted, :fetched_month => @@fetched_month,
      # :current_fetched_sessions_ids => @@current_fetched_sessions_ids,
      # :user_lactic_sessions => @@user_lactic_sessions}

    end
  end


  def set_globals_from_user_session(uid)

    $users_common_sessions[uid][:hash_sessions] = @lactic_sessions_hash
    $users_common_sessions[uid][:sessions] = @lactic_sessions
    $users_common_sessions[uid][:weekly_sessions] = @weekly_sessions
    $users_common_sessions[uid][:current_fetched_sessions_ids] = @current_fetched_sessions_ids
    $users_common_sessions[uid][:user_lactic_sessions] = @user_lactic_sessions
    $users_common_sessions[uid][:deleted] = @deleted

  end

  def set_monthly_sessions_schedule(start_month_date,start_year_date,current_user_uid,matched_user_uid)
    lactic_sessions_hash = Hash.new
    lactic_sessions_arr = []
    sdate_time = Time.zone.parse("#{start_year_date}-#{start_month_date}-1").to_datetime

    if (sdate_time)

      (0..4).each do |i|
        hash = set_weekly_schedule(sdate_time,current_user_uid,matched_user_uid)
        hash[:hash_sessions].each do |key,value|
          lactic_sessions_hash[key] = value
        end
        lactic_sessions_arr = lactic_sessions_arr+hash[:sessions]
        sdate_time = DateTime.parse((Time.parse(sdate_time.to_s)+7.days).to_s)
      end
    end
    {:hash_sessions => lactic_sessions_hash,:sessions =>  lactic_sessions_arr}

  end
  def set_weekly_schedule(start_week_date,current_user_uid,matched_user_uid)

    lactic_session_model = LacticSession.new
    lactic_sessions_hash = Hash.new
    # lactic_sessions = (current_user_uid)? LacticSession.get_all_user_sessions(current_user_uid,start_week_date,current_user_uid) : []
    lactic_sessions = (current_user_uid)? lactic_session_model.get_all_user_sessions(current_user_uid,start_week_date,current_user_uid) : []
    final_lactic_sessions = Array.new

    lactic_sessions.each do |lactic_session|
      if lactic_session && lactic_session.start_date_time <= start_week_date+7.days && !lactic_session.deleted
        if (lactic_session.end_date_time)
          # && lactic_session.repeat == 0)
        else
          lactic_session.to_weekly_session(start_week_date)
        end
        lactic_session_hash = lactic_session.to_lactic_hash
        final_lactic_sessions << lactic_session
        lactic_session_hash = LacticSession.to_weekly_sessiosn_hash(lactic_session_hash,start_week_date)

        id = (lactic_session.creator_fb_id==current_user_uid)? lactic_session.creator_fb_id : "friend-#{lactic_session.creator_fb_id}"
        redirect_id ="#{id}-#{lactic_session.id}-#{(lactic_session.start_date_time.to_f * 1000).to_i}"

        lactic_sessions_hash[redirect_id] = lactic_session_hash
      end
    end

    {:hash_sessions => lactic_sessions_hash,:sessions =>  final_lactic_sessions}

  end










end