module LacticSessionsHelper


  TYPE_DANCE = 'dance'
  TYPE_AEROBIC = 'aerobics'
  TYPE_CYCLE = 'cycle'
  TYPE_CORE = 'yoga'
  TYPE_WEIGHTS = 'weights'
  TYPE_PERSONAL = 'personal'
  TYPE_GYM = 'gym'
  TYPE_OUTDOORS = 'outdoors'
  TYPE_RUN = 'running'
  TYPE_OTHER = 'other'

  DEFAULT_IMAGE = 'fitness-pic.jpg'
  BIKE_IMAGE = 'bike.png'
  WEIGHT_IMAGE = 'weightlifting.png'
  CARDIO_IMAGE = 'running.png'


  SESSION_TYPE = [TYPE_OTHER,TYPE_AEROBIC, TYPE_CORE,TYPE_CYCLE,TYPE_DANCE,TYPE_GYM,TYPE_OUTDOORS,TYPE_PERSONAL,TYPE_RUN,TYPE_WEIGHTS]

  def type_session(type)

    type = pre_process_type(type)
    (type)? (SESSION_TYPE.index(type))? SESSION_TYPE.index(type) : 0 : 0

  end

  def pre_process_type(type_name)
    type = (type_name)? type_name : 'other'

    type = type.split(',')[0]
    type = (type)? type.downcase : 'other'
    type = (type)? type.split(" ")[0] : 'other'
    type ||='other'

    type
  end

  def self.image_by_type(type)

    # type ||= 0

    case SESSION_TYPE[type]
      when TYPE_CYCLE
        BIKE_IMAGE
      when TYPE_WEIGHTS, TYPE_GYM, TYPE_PERSONAL
       WEIGHT_IMAGE
      when TYPE_RUN, TYPE_OUTDOORS
        CARDIO_IMAGE
      else
        DEFAULT_IMAGE
    end

  end

  def self.image_from_title(title)


    types = title.split(' ')


    type_image = DEFAULT_IMAGE
    types.each do |type|
      type = (type)? type.downcase : 'other'
      # puts "SEARCHING FOR TYPE #{type} include #{TYPE_CYCLE}"
      if  type.include?(TYPE_WEIGHTS)
          type_image = WEIGHT_IMAGE
      else
        if type.include?(TYPE_RUN) ||
            type.include?(TYPE_AEROBIC) ||
            type.include?(TYPE_OUTDOORS)
          type_image =CARDIO_IMAGE
        else

          if type.include?(TYPE_PERSONAL) || type.include?(TYPE_GYM)
            type_image =WEIGHT_IMAGE
          else

            if type.include?(TYPE_CYCLE)
              type_image = BIKE_IMAGE
            end
          end
        end
      end
    end
    type_image


  end

  def lactic_session_path(lactic_session, options={})
    lactic_session_url(lactic_session, options.merge(:only_path => true))
  end


  def public_lactic_session_path(lactic_session, options={})
    public_lactic_session_url(lactic_session,options.merge(:only_path => true))
  end

  def lactic_session_url(lactic_session, options={})
    # puts "CURRENT SESSION #{osm_session.title} IS #{osm_session.friend_session}"
    # if (lactic_session.friend_session)
    #
    #   lactic_session_uid =  "friend-#{lactic_session.creator_fb_id}"
    #   # lactic_session_uid =  "invite-#{lactic_session.creator_fb_id}"
    # else
    #   lactic_session_uid = lactic_session.creator_fb_id
    # end

    lactic_session_uid =(lactic_session.invite_session)? "invite-#{lactic_session.creator_fb_id}" :
        (lactic_session.friend_session)? "friend-#{lactic_session.creator_fb_id}" :

            lactic_session.creator_fb_id

    action =
    url_for(options.merge(:controller => 'lactic_sessions', :action => 'show',
                          :id => "#{lactic_session_uid}-#{lactic_session.id}-#{(lactic_session.start_date_time.to_f * 1000).to_i}"))
  end

  def public_lactic_session_url(lactic_session,options={})
    # if (lactic_session.friend_session)
    #
    #   lactic_session_uid =  "friend-#{lactic_session.creator_fb_id}"
    #   # lactic_session_uid =  "invite-#{lactic_session.creator_fb_id}"
    # else
    #   lactic_session_uid = lactic_session.creator_fb_id
    # end

    lactic_session_uid = (lactic_session.invite_session)? "invite-#{lactic_session.creator_fb_id}" :
        (lactic_session.friend_session)? "friend-#{lactic_session.creator_fb_id}" :

            lactic_session.creator_fb_id

    url_for( options.merge(:controller => 'lactic_sessions', :action => 'show_public',
                           :id => "#{lactic_session_uid}-#{lactic_session.id}-#{(lactic_session.start_date_time.to_f * 1000).to_i}"))
  end


end
