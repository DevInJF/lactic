class LacticSession < ActiveRecord::Base

  attr_accessor :locations, :votes, :comments, :comment, :invitees, :view_invitees
  after_initialize :get_datetimes # convert db format to accessors
  validates_presence_of :title, :start_date_time, :location

  validates :title, presence: true
  validates :start_date_time, presence: true
  validates :location, presence: true

  attr_accessor :redirect_id, :instagram_image
  attr_accessor :view_type, :type_image
  attr_accessor :start_date, :start_time, :day_session
  attr_accessor :date_start, :time_start, :day_session
  attr_accessor :end_date, :end_time
  attr_accessor :year_view_date, :month_view_date
  attr_accessor :date_end, :time_end
  attr_accessor :month_view_date, :year_view_date
  attr_accessor :repeat, :creator, :friend_session, :invite_session
  attr_accessor :inviter_id, :inviter_name, :inviter_picture

  include PostgresLacticSessions
  include PostgresSessionsRetrieves
  include LacticSessionsHelper
  def get_datetimes
    self.start_date_time ||= Time.now  # if the published_at time is not set, set it to now

    self.start_date ||= self.start_date_time.to_date.to_s(:db) # extract the date is yyyy-mm-dd format
    self.start_time ||= "#{'%02d' % self.start_date_time.getlocal().hour}:#{'%02d' % self.start_date_time.getlocal().min}" # extract the time

    self.end_date_time ||= Time.now  # if the published_at time is not set, set it to now

    self.end_date ||= self.end_date_time.to_date.to_s(:db) # extract the date is yyyy-mm-dd format
    self.end_time ||= "#{'%02d' % self.end_date_time.getlocal().hour}:#{'%02d' % self.end_date_time.getlocal().min}" # extract the time


    self.day_session ||= "TODAY"
  end

  def set_datetimes

    self.start_date_time = Time.parse("#{self.start_date},#{self.start_time}:00").utc.to_datetime # convert the two fields back to db
    self.end_date_time   = Time.parse("#{self.end_date},#{self.end_time}:00").utc.to_datetime # convert the two fields back to db

  end


  def set_from_view (form_params)


    self.start_date_time = Time.parse("#{form_params["start_date"]},#{form_params["start_time"]}:00").to_datetime # convert the two fields back to db

    self.end_date_time   = Time.parse("#{form_params["end_date"]},#{form_params["end_time"]}:00").to_datetime # convert the two fields back to db

    self.title = form_params["title"]
    self.description = form_params["description"]
    self.location = form_params["location"]
    self.location_id = form_params["location_id"]
    self.location_origin = form_params["location_origin"]
    # self.shared = form_params["shared"] == "1"
    self.shared = true
    self.month_view_date = (form_params["month_view_date"])?form_params["month_view_date"].to_i  : nil
    self.deleted = false
    self.view_type = form_params["view_type"]
    set_lactic_type
  end


  def set_from_schedule_view (form_params,user_fb_id,user_id)


    # puts "FORM LACTIC PARAMS #{form_params.inspect}"
    # puts "FORM DATE LACTIC PARAMS #{form_params["date_start"].gsub('/','-')}"
    # puts "FORM DATE LACTIC PARAMS #{form_params["date_start"].gsub('/','-')}"
    s_time =form_params["time_start"]

    e_time =form_params["time_end"]

    # puts "INSPECT FORM VIEW #{form_params.inspect}"
    # datetimeparse = form_params["start_date"].to_datetime
    datetimeparse = form_params["date_start"].to_datetime

    time = datetimeparse.strftime('%d/%m/%Y')+" #{s_time}"
    # puts "INSPECT FORM VIEW TIME START #{time}"
    # datetimeparse_e = form_params["end_date"].to_datetime
    datetimeparse_e = form_params["date_end"].to_datetime

    time_e = datetimeparse_e.strftime('%d/%m/%Y')+" #{e_time}"


    self.start_date_time =Time.zone.parse(time.clone).to_datetime
    # puts "INSPECT FORM VIEW STRAT DATE TIME   #{self.start_date_time}"
    # enddatetimeparse = (form_params["date_end"].nil? || form_params["date_end"].empty?)? nil : form_params["end_date"].to_datetime
    #
    # etime = (form_params["date_end"].nil? || form_params["date_end"].empty?)? nil : enddatetimeparse.strftime('%d/%m/%Y')+" #{e_time}"

    # self.end_date_time   = (form_params["date_end"].nil? || form_params["date_end"].empty?)? nil : Time.parse(etime).to_datetime.utc # convert the two fields back to db
    self.end_date_time   = (form_params["date_end"].nil? || form_params["date_end"].empty?)? nil : Time.parse(time_e).to_datetime # convert the two fields back to db


    self.title = form_params["title"]
    self.creator_id = user_id
    self.creator_fb_id = user_fb_id
    self.description = form_params["description"]
    self.location = form_params["location"]
    self.location_id = form_params["location_id"]
    self.location_origin = form_params["location_origin"]
    # self.shared = form_params["shared"] == "1"
    self.shared = true

    self.week_day = form_params["day_session"]||""
    self.repeat = form_params["repeat"].to_i||0
    self.month_view_date = (form_params["month_view_date"])?form_params["month_view_date"].to_i  : nil

    # end_time   = (form_params["date_end"].nil? || form_params["date_end"].empty?)?
    #     Time.parse(time_e).to_datetime.utc :
    #     Time.parse(etime).utc.to_datetime # convert the two fields back to db
    # start_time = Time.parse(time).to_datetime.utc # convert the two fields back to db

    self.duration = ((Time.parse(time_e).to_datetime- Time.parse(time).to_datetime) * 24 * 60).to_i || 0


    self.end_date_time   = (self.repeat == 1)? nil : Time.zone.parse(self.end_date_time.to_s)


    self.deleted = false
    # puts "INSPECT END FORM VIEW BEFORE #{self.end_date_time.inspect}"
    self.view_type = form_params["view_type"]
    set_lactic_type

    # puts "LACTIC FROM VIEW  #{self.inspect}"


  end

  def calc_duration
    seconds_diff =((self.end_date_time- self.start_date_time) * 24 * 60).to_i
    seconds_diff.abs
  end

  def as_json(options = {})
    {

        :id => self.id,
        # :osm_id => self.osm_id,
        # :location => self.location,
        :location_id => self.location_id,
        :title => self.title,
        :description =>  "OSM DESCRIPTION #{self.description}" || '',
        :location =>  "OSM LOCATION #{self.location}" || '',
        :start_date_time => self.start_date_time,
        # :start => self.start_date_time.rfc822,
        :end_date_time => self.end_date_time,
        # :end => self.end_date_time.rfc822,
        :allDay => false,
        :recurring => false,
        :user_vote => self.user_vote ,
        :osm_creator_name => self.osm_creator_name,
        :duration => self.duration || 0,
        :week_day => self.week_day || 0,
        :day_session => self.day_session,
        :deleted => self.deleted || false,
        :type => self.type || 0,
        # :url => Rails.application.routes.url_helpers.event_path(id),
        #:color => "red"

    }

  end



  ### ADDED UTC TO REDIRET ID.....?????? (MAY 1)
  def save_last_fetch(sessions,uid,month_date,matched_uid,invitee)

    sessions_arr = ''
    hashed_sessions_by_id = ''
    sessions.each do|session|
      LacticSession.validate_for_save(session)
      hash = (session)? session.to_lactic_json : ''
      sessions_arr.concat(hash.gsub("'", '"'))
      sessions_arr += ","
      id = (session.invite_session)? "invite-#{session.creator_fb_id}" :
          (session.friend_session)? "friend-#{session.creator_fb_id}" :
              session.creator_fb_id
      redirect_id ="#{id}-#{session.id}-#{(session.start_date_time.utc.to_f * 1000).to_i}"
      hashed_sessions_by_id.concat("{'#{redirect_id}': '#{hash}'},")

    end
    sessions_arr = '[' + sessions_arr + ']'
    sessions_arr = sessions_arr.gsub(',}]', '}]')
    hashed_sessions_by_id = '[' + hashed_sessions_by_id + ']'
    hashed_sessions_by_id = hashed_sessions_by_id.gsub(',]', ']').gsub("'", '"').gsub('}{', '},{').gsub(': "{', ': {').gsub('}"]', '}]').gsub(',}', '}').gsub('"}"}', '"}}').gsub('{"{', '{{')
    sessions_arr = sessions_arr.gsub(',]', ']').gsub("'", '"').gsub('}{', '},{').gsub(',}', '}').gsub(': "{', ': {').gsub('}"]', '}]').gsub(',}', '}').gsub('"}"}', '"}}').gsub('{"{', '{{')
    invitee_uid = (invitee)? invitee : uid
    user_session = (invitee)? true : false

    # PostgresSessionsRetrieves.save_last_fetch(sessions_arr.gsub('}{', '},{'),hashed_sessions_by_id.gsub('}{', '},{'),invitee_uid,user_session,month_date)
    save_pg_last_fetch(sessions_arr.gsub('}{', '},{'),hashed_sessions_by_id.gsub('}{', '},{'),invitee_uid,user_session,month_date)

  end



  def self.validate_for_save(session)

    if session
      session.title = PostgresHelper.escape_title_descriptions(session.title)
      session.description = PostgresHelper.escape_title_descriptions(session.description)
      session.location = (session.location)? PostgresHelper.escape_title_descriptions(session.location) : session.location


      if !session.location_origin
        session.location_origin = (session.location_id && session.location_id.to_i && session.location_id.to_i !=0)? 'facebook' : 'google'
      end

    end
    session
  end


  def save_new_session

    self.start_date_time = self.start_date_time.utc
    self.end_date_time = (self.end_date_time)? self.end_date_time.utc  : self.end_date_time
    LacticSession.validate_for_save(self)

    save_pg_new_lactic(self,self.creator_id)
  end


  def self.format_date(date_time)
    Time.at(date_time.to_i).to_formatted_s(:db)
  end

  def weekly_sessions(lactic_session,start_week_date)

    if(lactic_session)

      session_replica = SessionReplica.get_by_origin(lactic_session.id,start_week_date)
      if session_replica
        ###  got replica for this week with added/edited info
        lactic_session = session_replica.lactic_session
      else
        ### use the origin lactic template session
        if (lactic_session.week_day)
          day = (start_week_date + (((lactic_session.week_day-start_week_date.strftime("%u").to_i)).modulo 7).days)
          time  = lactic_session.start_date_time
          sdate_time = Time.parse("#{day.strftime('%Y/%m/%d')},#{time.hour}:#{time.min}:#{time.sec}").to_datetime.utc
        end
        lactic_session.start_date_time =(!sdate_time.nil?)?sdate_time.to_datetime :
            (lactic_session.start_date_time >= start_week_date)?
                lactic_session.start_date_time:
                (lactic_session.end_date_time)?
                    (lactic_session.end_date_time.to_datetime>=start_week_date)?
                        start_week_date:lactic_session.end_date_time-7.days:
                    sdate_time.to_datetime;

        lactic_session.end_date_time = (lactic_session.end_date_time)? lactic_session.end_date_time : lactic_session.start_date_time + lactic_session.duration.minutes
      end
    end
    lactic_session
  end






  def get_by_id(id,user_request_id)
    id =  id.to_s.gsub('friend-','').gsub('invite-','').gsub('id=','')


    puts "SEARCH BY ID #{id}"

    # PostgresLacticSessions.get_by_id(id,user_request_id)
    get_pg_by_id(id,user_request_id)
  end


  ## Return an array of LacticSessions for that user_id and from that start datetime
  def get_all_user_sessions(user_uid,start_date,user_request_id)
    # PostgresLacticSessions.get_by_uid(user_uid,start_date,user_request_id)
    get_pg_by_uid(user_uid,start_date,user_request_id)
  end


  def get_all_last_fetch(user_uid,month_start_date,month_end_date)

    a1 = last_user_sessions_fetch(user_uid,month_start_date,month_end_date)
    a2 = last_contact_sessions_fetch(user_uid,month_start_date,month_end_date)

    fetch_a1 = (a1 && a1[:last_fetch])?a1[:last_fetch] : []
    fetch_a2 = (a2 && a2[:last_fetch])?a2[:last_fetch] : []


    fetch_hash_a1 = (a1 && a1[:last_hashed_fetch_result])?a1[:last_hashed_fetch_result] : {}
    fetch_hash_a2 = (a2 && a2[:last_hashed_fetch_result])?a2[:last_hashed_fetch_result] : {}
    deleted1 = (a1 && a1[:deleted_sessions])?a1[:deleted_sessions] : Array.new
    deleted2 = (a2 && a2[:deleted_sessions])?a2[:deleted_sessions] : Array.new

    deleted = deleted1.concat(deleted2)

    last_fetch =  (fetch_a1 << fetch_a2).flatten!

    last_hashed_fetch_result = (fetch_hash_a1.merge(fetch_hash_a2))

    {:sessions => last_fetch, :hash_sessions => last_hashed_fetch_result, :deleted_sessions => deleted}

  end


  def user_sessions_fetch(user_uid,month_start_date,month_end_date)
    a1 = last_user_sessions_fetch(user_uid,month_start_date,month_end_date)
    fetch_a1 = (a1 && a1[:last_fetch])?a1[:last_fetch] : []
    fetch_hash_a1 = (a1 && a1[:last_hashed_fetch_result])?a1[:last_hashed_fetch_result] : {}
    last_fetch =  fetch_a1
    last_hashed_fetch_result = fetch_hash_a1
    deleted = (a1 && a1[:deleted_sessions])?a1[:deleted_sessions] : Array.new


    {:sessions => last_fetch, :hash_sessions => last_hashed_fetch_result, :deleted_sessions => deleted}

  end

  def contact_sessions_fetch(user_uid,month_start_date,month_end_date)
    a2 = last_contact_sessions_fetch(user_uid,month_start_date,month_end_date)
    fetch_a2 = (a2 && a2[:last_fetch])?a2[:last_fetch] : []
    fetch_hash_a2 = (a2 && a2[:last_hashed_fetch_result])? a2[:last_hashed_fetch_result] : {}
    last_fetch =  fetch_a2
    last_hashed_fetch_result = fetch_hash_a2


    # puts "LAST FETCH RESULT #{last_hashed_fetch_result.inspect}"


    deleted_sessions = (a2 && a2[:deleted_sessions])?a2[:deleted_sessions] : Array.new

    {:sessions => last_fetch, :hash_sessions => last_hashed_fetch_result, :deleted_sessions => deleted_sessions}

  end




  def last_contact_sessions_fetch(user_uid,month_start_date,month_end_date)
    # PostgresSessionsRetrieves.last_retrieves(user_uid,true,month_start_date,month_end_date)
    last_pg_retrieves(user_uid,true,month_start_date,month_end_date)
  end

  def last_user_sessions_fetch(user_uid,month_start_date,month_end_date)
    # PostgresSessionsRetrieves.last_retrieves(user_uid,false,month_start_date,month_end_date)
    last_pg_retrieves(user_uid,false,month_start_date,month_end_date)
  end

  def hashed_lactic_session
    hash = {}
    if self.id
      hash[self.id] = self
    end
    hash
  end


  def to_lactic_json
    lactic_session = self
    lactic_json = ''

    if lactic_session

      lactic_json = "{'id' : '#{lactic_session.id}','title' : '#{lactic_session.title.gsub("'",'%q')}',
'description' : '#{lactic_session.description.gsub("'",'%q')}','start_date_time' : '#{lactic_session.start_date_time.utc.strftime('%Y-%m-%d %H:%M:%S')}',
'location' : '#{lactic_session.location.gsub("'",'%q')}','location_origin' : '#{lactic_session.location_origin}','location_id' : '#{lactic_session.location_id}',
'duration' : '#{lactic_session.duration}','week_day' : '#{lactic_session.week_day}',
'inviter_name' : '#{lactic_session.inviter_name}','inviter_id' : '#{lactic_session.inviter_id}',
'creator_fb_id' : '#{lactic_session.creator_fb_id}','creator_id' : '#{lactic_session.creator_id}','inviter_picture' : '#{lactic_session.inviter_picture}',"
      lactic_json = (lactic_session.end_date_time)? lactic_json + "'end_date_time' : '#{lactic_session.end_date_time.utc.strftime('%Y-%m-%d %H:%M:%S')}'," :lactic_json
      lactic_json = (lactic_session.created_at)? lactic_json + "'created_at' : '#{lactic_session.created_at}'," :lactic_json
      lactic_json = (lactic_session.updated_at)? lactic_json + "'updated_at' : '#{lactic_session.updated_at}'," :lactic_json


      lactic_json = (lactic_session.date_deleted)? lactic_json + "'date_deleted' : '#{lactic_session.date_deleted}'," : lactic_json
      lactic_json = (lactic_session.deleted)? lactic_json + "'deleted' : '#{lactic_session.deleted}'," : lactic_json + "'deleted' : 'false', "
      lactic_json = (lactic_session.type)? lactic_json + "'type' : '#{lactic_session.type}'" : lactic_json + "'type' : '0' "
      lactic_json = (lactic_session.instagram_image)? lactic_json + ",'instagram_image' : '#{lactic_session.instagram_image}'" : lactic_json

      lactic_json += '}'
      lactic_json = lactic_json.gsub(",}", "}")
      lactic_json = lactic_json.gsub("'", '"')
    end

    # puts "LACTIC JSON PRESENTATION #{lactic_json.gsub("'", '"').gsub(',}', '}')}"


    lactic_json = lactic_json.gsub(',}', '}')



    lactic_json = lactic_json.gsub("'", '"')
    lactic_json = lactic_json.gsub('",}', '"}')
    # puts "LACTIC JSON PRESENTATION ==== #{lactic_json}"
    lactic_json
  end

  def to_lactic_hash

    lactic_session = self
    # puts "FROM HASH.... #{lactic_session.inspect}"

    lactic_hash = {}

    if lactic_session
      # lactic_session = LacticSession.new
      lactic_hash["id"] = lactic_session.id
      lactic_hash["title"] = lactic_session.title
      lactic_hash["description"]= lactic_session.description
      lactic_hash["start_date_time"] = lactic_session.start_date_time
      if (lactic_session.end_date_time)
        lactic_hash["end_date_time"] = lactic_session.end_date_time

      end
      lactic_hash["location"] = lactic_session.location
      lactic_hash["location_id"] = lactic_session.location_id
      lactic_hash["location_origin"] = lactic_session.location_origin
      lactic_hash["duration"] = lactic_session.duration
      lactic_hash["week_day"] = lactic_session.week_day
      lactic_hash["creator_fb_id"] = lactic_session.creator_fb_id
      lactic_hash["shared"] = lactic_session.shared
      if (lactic_session.created_at)
        lactic_hash["created_at"] = lactic_session.created_at
      end
      if (lactic_session.updated_at)
        lactic_hash["updated_at"] = lactic_session.updated_at
      end

      lactic_hash["creator_id"] = lactic_session.creator_id
      lactic_hash["inviter_id"] = lactic_session.inviter_id
      lactic_hash["inviter_name"] = lactic_session.inviter_name
      lactic_hash["deleted"] = (lactic_session.deleted)? lactic_session.deleted : false
      if lactic_session.date_deleted
        lactic_hash["date_deleted"] = lactic_session.date_deleted
      end
      lactic_hash["type"] = (lactic_session.type)? lactic_session.type.to_s : '0'
      lactic_hash["instagram_image"] = (lactic_session.instagram_image)? lactic_session.instagram_image.to_s : ''

    end

    lactic_hash

  end



  def delete_session
    # PostgresLacticSessions.delete_session(self.id, self.date_deleted)
    delete_pg_session(self.id, self.date_deleted)
  end

  def self.is_numeric (str)
    Float(str) != nil rescue false
  end
  def self.from_hash(lactic_hash,user_request_id, invite_session=nil)

    lactic_session = nil
    if lactic_hash && !lactic_hash.empty? && lactic_hash["start_date_time"]
      puts "LACTIC FROM HASH #{lactic_hash["start_date_time"].to_s.to_datetime.strftime('%Y-%m-%d %H:%M:%S').to_datetime }"
      lactic_session = LacticSession.new
      lactic_session.id = lactic_hash["id"].to_i
      lactic_session.title = (lactic_hash["title"])? PostgresHelper.unescape_title_descriptions(lactic_hash["title"]): ''
      lactic_session.description = (lactic_hash["description"])? PostgresHelper.unescape_title_descriptions(lactic_hash["description"]):''

      lactic_session.start_date_time = lactic_hash["start_date_time"].to_s.to_datetime.strftime('%Y-%m-%d %H:%M:%S').to_datetime

      # puts "FROM HASH START TIME === #{lactic_session.start_date_time} LOCAL #{lactic_session.start_date_time.getlocal()} RECORD #{lactic_hash["start_date_time"]}"
      lactic_session.location = (lactic_hash["location"])? PostgresHelper.unescape_title_descriptions(lactic_hash["location"]): ''
      lactic_session.location_id = lactic_hash["location_id"]|| ''


      origin = ()

      lactic_session.location_origin = lactic_hash["location_origin"]|| ''


      if !lactic_session.location_origin
        lactic_session.location_origin = (lactic_session.location_id && lactic_session.location_id.to_i && lactic_session.location_id.to_i !=0)? 'facebook' : 'google'
      end


      # if lactic_hash["location_origin"] && lactic_session.location_id && !lactic_session.location_id.empty?
      #
      #   lactic_session.location_origin = (lactic_session.location_origin.empty?)? (lactic_session.location_id.is_a? (Numeric)) ? 'facebook' : 'google' : lactic_session.location_origin
      # end


      lactic_session.duration = lactic_hash["duration"].to_i || 0
      lactic_session.end_date_time = (lactic_hash["end_date_time"])?lactic_hash["end_date_time"].to_s.to_datetime.strftime('%Y-%m-%d %H:%M:%S').to_datetime : nil
      # lactic_session.end_date_time = (lactic_hash["end_date_time"])?Time.parse(lactic_hash["end_date_time"].to_s).utc.iso8601 : nil

      lactic_session.week_day = lactic_hash["week_day"].to_i
      lactic_session.creator_fb_id = lactic_hash["creator_fb_id"]
      lactic_session.shared = lactic_hash["shared"]
      lactic_session.created_at = (lactic_hash["created_at"])? Time.parse(lactic_hash["created_at"].to_datetime.to_s) : Time.zone.now
      lactic_session.updated_at = (lactic_hash["updated_at"])?Time.parse(lactic_hash["updated_at"].to_datetime.to_s) : Time.zone.now
      lactic_session.creator_id = lactic_hash["creator_id"]
      lactic_session.friend_session = user_request_id != lactic_session.creator_fb_id
      lactic_session.inviter_id = lactic_hash["inviter_id"]
      lactic_session.inviter_name = lactic_hash["inviter_name"]
      lactic_session.inviter_picture = lactic_hash["inviter_picture"]


      lactic_session.invite_session =  lactic_session.inviter_id && lactic_session.inviter_name && lactic_session.inviter_id != ''

      lactic_session.deleted = lactic_hash["deleted"]
      lactic_session.date_deleted = (lactic_hash["date_deleted"])?Time.parse(lactic_hash["date_deleted"].to_datetime.to_s) : nil



      lactic_session.type = lactic_hash["type"].to_i
      # lactic_session.type_image = lactic_hash["type"].to_i
      lactic_session.instagram_image = lactic_hash["instagram_image"]

      # if (lactic_session.id == 161)
      #   # puts "TYPE FROM PG #{lactic_hash["type"]}"
      #   # puts  "TYPE FROM LACTIC SESSION #{lactic_session.type}"
      # end

      lactic_session.type_image = LacticSessionsHelper.image_by_type(lactic_session.type)

      lactic_session.invitees = Array.new
      lactic_session.votes = Array.new
      lactic_session.comments  = Array.new
      lactic_session.invite_session ||= invite_session

      # lactic_session.set_lactic_type
      lactic_session.set_lactic_image_type
    end
    lactic_session

  end
  def self.from_hashed_hash(lactic_hash_hashed,user_request_id,invite_retrieve)
    hash = Hash.new
    lactic_hash_hashed.each do |key,value|
      hash[key] = from_hash(value,user_request_id,invite_retrieve)
    end

    hash
  end


  def copy_session
    new_session = LacticSession.new
    new_session.id = self.id
    new_session.title = self.title
    new_session.description = self.description
    new_session.start_date_time = self.start_date_time
    new_session.end_date_time = self.end_date_time
    new_session.location = self.location
    new_session.location_id = self.location_id
    new_session.duration = self.duration
    new_session.week_day = self.week_day
    new_session.creator_fb_id = self.creator_fb_id
    new_session.shared = self.shared
    new_session.created_at = self.created_at
    new_session.updated_at = self.updated_at
    new_session.creator_id = self.creator_id
    new_session.deleted = self.deleted
    new_session.date_deleted = self.date_deleted
    new_session.location_origin = self.location_origin
    new_session.type = self.type
    # new_session.type_image = self.type
    new_session.instagram_image = self.instagram_image


    new_session

  end

  def to_monthly_sessions(start_month_date)
    monthly_session = Array.new
    (1..5).each do |i|
      week_session = self.copy_session
      week_session.to_weekly_session(start_month_date)
      if week_session.start_date_time
        # && week_session.start_date_time <= start_month_date+7.days
        monthly_session << week_session
      end
      start_month_date = DateTime.parse((Time.parse(start_month_date.to_s)+7.days).to_s)
    end
    monthly_session
  end

  def to_weekly_session(start_week_date)

    if self

      if self.week_day
        day = (start_week_date + (((self.week_day-start_week_date.strftime("%u").to_i)).modulo 7).days)
        sdate_time = Time.zone.parse("#{day.strftime('%Y/%m/%d')},#{self.start_date_time.hour}:#{self.start_date_time.min}:#{self.start_date_time.sec}").to_datetime
      end
      self.start_date_time =(self.start_date_time > start_week_date+7.days)?
          nil:(self.start_date_time <= start_week_date+7.days && self.start_date_time >= start_week_date)? self.start_date_time :
          (!sdate_time.nil?)?
          sdate_time.to_datetime :
              (self.end_date_time)?
                  (self.end_date_time == start_week_date)?
                      start_week_date:self.end_date_time.to_datetime-7.days:
                  sdate_time.to_datetime;
      self.end_date_time =  (self.start_date_time.nil?)? nil : self.start_date_time + self.duration.minutes
    end


    end

  def self.to_weekly_sessiosn_hash(session_hash, start_week_date)

    if session_hash

      if session_hash["week_day"]
        day = (start_week_date + (((session_hash["week_day"]-start_week_date.strftime("%u").to_i)).modulo 7).days)
        sdate_time = Time.parse("#{day.strftime('%Y/%m/%d')},#{session_hash["start_date_time"].hour}:#{session_hash["start_date_time"].min}:#{session_hash["start_date_time"].sec}").to_datetime.utc
      end


      session_hash["start_date_time"] =(!sdate_time.nil?)?sdate_time.to_datetime :
          (session_hash["start_date_time"] >= start_week_date)?
          session_hash["start_date_time"]:
              (session_hash["end_date_time"])?
                  (session_hash["end_date_time"]=start_week_date)?
                      start_week_date:session_hash["end_date_time"].to_datetime-7.days:
                  sdate_time.to_datetime;
      session_hash["end_date_time"] = (session_hash["end_date_time"])? session_hash["end_date_time"].to_datetime : session_hash["start_date_time"].to_datetime + session_hash["duration"].to_i.minutes
    end
    session_hash
  end



  def all_between(day1,day2,uid,user_request_id)

    # lactic_sessions = PostgresLacticSessions.all_between(day1,day2,uid,user_request_id)
    lactic_sessions = all_pg_between(day1,day2,uid,user_request_id)

    between_sessions = []
    lactic_sessions.each do |lactic_session|
      if !lactic_session.deleted
        lactic_session.between(day1)
        if lactic_session.start_date_time <= lactic_session.end_date_time && lactic_session.start_date_time >= day1 && lactic_session.end_date_time <= day2
          between_sessions << lactic_session
        end
      end
    end

    between_sessions
  end


  def between(start_week_date)


    day = (start_week_date + (((self.week_day-start_week_date.strftime("%u").to_i)).modulo 7).days)

    sdate_time = Time.parse("#{day.strftime('%Y/%m/%d')},#{self.start_date_time.hour}:#{self.start_date_time.min}:#{self.start_date_time.sec}").to_datetime.utc

  self.start_date_time =(!sdate_time.nil?)?sdate_time.to_datetime :
      (start_date.to_datetime >= start_week_date)?
          start_date.to_datetime:
          (start_date)?
              (start_date.to_datetime>=start_week_date)?
                  start_week_date:start_date.to_datetime-7.days:
              sdate_time.to_datetime;
    self.end_date_time = (self.end_date_time)? self.end_date_time : self.start_date_time + self.duration.minutes

  end

  def self.to_hash_by_direct_id(sessions,user_request_id)
    hash = Hash.new
    sessions.each do |session|
      id = (session.creator_fb_id==user_request_id)? session.creator_fb_id : "friend-#{session.creator_fb_id}"
      redirect_id ="#{id}-#{session.id}-#{(session.start_date_time.to_f * 1000).to_i}"
      hash[redirect_id] = session
    end
    hash
  end




  def update_sessions_fetched(sessions_arr,user_request_id,contacts_sessions,matched_uid)
    if self.id

      # puts "REPEAT?????? #{self.repeat}"
      if (self.end_date_time  && !self.deleted && self.repeat == 0)

        ## ONE TIME SESSION
        sessions_arr << self
      else
        ### WEEKLY REPEATED SESSION
        if !self.deleted

          # monthly_session = to_monthly_sessions(DateTime.now)
          monthly_session = to_monthly_sessions(self.start_date_time)
          sessions_arr = sessions_arr.concat(monthly_session)
        end
      end
      # puts "BEFORE SAVE #{sessions_arr.inspect}"
      save_last_fetch(sessions_arr,user_request_id,DateTime.now,matched_uid,nil)




    end
  end


  def invite_to_session(inviter, invitee_uid,matched_uid)
    if (inviter.matched && inviter.matched_user == invitee_uid && (self.creator_fb_id == invitee_uid || self.creator_fb_id == inviter.uid))
      # puts " NO NEED TO SHARE SESSIONS ON MATCHED CALENDAR..."
    else

      start_time = Time.parse("#{self.start_date_time.year}-#{self.start_date_time.month}-1").utc.to_datetime
      end_time = Time.parse("#{self.end_date_time.year}-#{self.end_date_time.month}-1").utc.to_datetime
      end_time = (end_time > start_time.utc.end_of_month)? end_time : start_time.utc.end_of_month

      # last_invitee_fetched = PostgresSessionsRetrieves.last_retrieves(invitee_uid,true,start_time,end_time)
      last_invitee_fetched = last_pg_retrieves(invitee_uid,true,start_time,end_time)

      last_fetched = (last_invitee_fetched)? last_invitee_fetched[:last_fetch] :  Array.new

      self.inviter_id = inviter.id
      self.inviter_name = inviter.name
      self.inviter_picture = inviter.picture
      LacticSession.validate_for_save(self)
      last_fetched << self

      # puts "SAVE LAST FETCH INVITE #{last_fetched.inspect}"
      save_last_fetch(last_fetched,inviter.uid,start_time,matched_uid,invitee_uid)
      # return false


    end
  end

  def update_fetch_delete(hash_id)
    result = false
    if self.date_deleted
      # result =PostgresSessionsRetrieves.delete_session_added(self.creator_id,self.date_deleted,hash_id,true)
      result =delete_pg_session_added(self.creator_id,self.date_deleted,hash_id,false)
    end
    result
  end

  def update_matched_fetch_delete(hash_id,match_id)
    result = false
    if self.date_deleted
      # result =PostgresSessionsRetrieves.delete_session_added(match_id,self.date_deleted,hash_id,false)
      result =delete_pg_session_added(match_id,self.date_deleted,hash_id,true)
    end
    result
    end

  def update_invitee_fetch_delete(hash_id,invitee_id)
    result = false
    if self.date_deleted
      # result =PostgresSessionsRetrieves.delete_session_added(match_id,self.date_deleted,hash_id,false)
      result =delete_pg_session_added(invitee_id,self.date_deleted,hash_id,true)
    end
    result
  end



  def lactic_from_replica_session (replica)

    self.invitees = Array.new
    if replica && replica.lactic_session
      self.start_date_time = (replica.start_date)? replica.start_date : self.start_date_time
      self.votes =  replica.lactic_session.votes
      self.comments = replica.lactic_session.comments
      self.invitees =  replica.lactic_session.invitees
      # puts "REPLICA TO SESSION WITH LOCATION #{replica.inspect}"
      # puts "REPLICA TO LACTIC SESSION #{replica.lactic_session.inspect}"
      self.location =  replica.lactic_session.location
      self.location_id =  replica.lactic_session.location_id
      self.location_origin =  replica.lactic_session.location_origin
      self.instagram_image =  replica.lactic_session.instagram_image
      self.type =  replica.lactic_session.type
      set_lactic_image_type
      if !self.location_origin || self.location_origin.empty?
        self.location_origin = (self.location_id && self.location_id.to_i && self.location_id.to_i !=0)? 'facebook' : 'google'
      end

    end

    # end
    self.end_date_time = self.start_date_time + self.duration.minutes
  end


  def public_lactic_no_replica (start_date)
    self.start_date_time = Time.at(start_date / 1000).to_datetime
    self.end_date_time = self.start_date_time + self.duration.minutes
  end

  def remove_from_invite(user_uid)
    month = self.start_date_time.month.to_i
    year = self.start_date_time.year

    lactic_sessions = Array.new
    lactic_sessions_hash = Hash.new

    user_contact_fetch = LacticSession.contact_sessions_fetch(user_uid,Time.parse("#{year}-#{month}-1").utc.to_datetime,Time.parse("#{year}-#{month+1}-1").utc.end_of_month)
    # puts "SESSION  BEFORE REMOVE #{user_contact_fetch[:sessions].length}"
    if user_contact_fetch
      user_contact_fetch[:sessions].each do|session|
        if session && session.id != self.id
          lactic_sessions << session
        end
      end
      if lactic_sessions.length > 0
        user_contact_fetch[:hash_sessions].each do |key,value|
          if value.id != self.id
            lactic_sessions_hash[key] = value
          end
        end
      end
    end

    # puts "SESSION  AFTER REMOVE #{lactic_sessions.length}"

    if lactic_sessions.length == 0
      # PostgresSessionsRetrieves.delete_last_fetch(user_uid.to_s,true,self.start_date_time)
      delete_pg_last_fetch(user_uid.to_s,true,self.start_date_time)
    else
      # PostgresSessionsRetrieves.save_last_fetch(lactic_sessions,lactic_sessions_hash,user_uid,true,self.start_date_time)
      save_pg_last_fetch(lactic_sessions,lactic_sessions_hash,user_uid,true,self.start_date_time)

    end

  end



  def valid_for_new_save
    self && self.start_date_time && self.location && !self.location.empty? && self.title && !self.title.empty? && self.creator_fb_id && !self.creator_fb_id.empty?
  end



  def set_lactic_type

    self.type = type_session(self.view_type)
    set_lactic_image_type

  end

  def set_lactic_image_type
    self.type_image = LacticSessionsHelper.image_by_type(self.type)
    if self.type == 0 && self.type_image == LacticSessionsHelper::DEFAULT_IMAGE
      self.type_image = LacticSessionsHelper.image_from_title(self.title)
    end
  end

end
