class SessionReplica < ActiveRecord::Base
  attr_accessor :lactic_session



  include PostgresSessionReplica

  def get_by_origin(origin_id,start_date)
    # puts "GET REPLICA FROM MODEL #{start_date}"
    # puts "GET REPLICA FROM MODEL UTC #{start_date.utc}"

    origin_id = (origin_id && !(origin_id.is_a? Integer))? origin_id.gsub('friend-','').gsub('invite-',''): origin_id



    puts "SEARCH BY ORIGIN ID #{origin_id}"
    get_pg_replica(origin_id,start_date)
  end

  def save_new_replica(lactic_session,start_replica_date)
    new_replica = SessionReplica.new
    new_replica.info = info_hash(lactic_session)
    new_replica.origin_id = lactic_session.id
    new_replica.start_date = start_replica_date

    save_pg_replica(new_replica)

  end


  def new_replica_info
    lactic_session = self.lactic_session
    result = nil
    if lactic_session && lactic_session.id && lactic_session.start_date_time
      result  = new_pg_info(lactic_session)
    end
    result
    end

  # def update_replica_info
  #   lactic_session = self.lactic_session
  #   result = nil
  #   if lactic_session && lactic_session.info && self.id
  #     result  = update_pg_info(self.id,lactic_session)
  #   end
  #   result
  # end

  def new_vote(new_vote,voter_name)
    # puts "iNSERT NEW  VOTES WITH VOTES #{new_vote.inspect}"

    self.votes = Array.new
    hash = Hash.new
    hash[new_vote] = voter_name
    self.votes << hash
    new_pg_vote(self.votes,self)

  end
  def update_votes(new_vote,voter_name, current_votes)
    # puts "UPDATING VOTES WITH VOTES #{new_vote.inspect} -    #{current_votes.inspect}"


    if !current_votes
      self.votes = Array.new
      current_votes =Array.new
    end

    hash = Hash.new
    hash[new_vote] = voter_name
    current_votes << hash
    h = {}
    current_votes.each{|i|i.each{|k,v|h[k] = v unless h[k]}}

    self.votes = Array.new

    h.each{|k,v|self.votes << {k=>v}}
    # puts "UPDATING VOTES WITH VOTES AFTER ADDING VOTE  #{self.votes.inspect}"
    # self.votes = h
    update_pg_votes(self.votes,self)

  end


  def escape_comment (comment)
    # (comment)? PostgresHelper.escape_for_postgres(comment) : ''
    (comment)? PostgresHelper.escape_title_descriptions(comment) : ''
  end

  def new_comment(user,comment )
    self.comments = Array.new
    hash = Hash.new
    comment_escaped = escape_comment (comment)
    hash[Time.zone.now.to_s] = {:id => user.id, :name => user.name, :comment => comment_escaped}
    self.comments << hash
    new_pg_comment(self.comments, self)
  end


  def update_comments(user, new_comment, current_comments)
    # puts "UPDATE COMMENT #{current_comments}"
    if !current_comments
      self.comments = Array.new
      current_comments =Array.new
    end

    hash = Hash.new
    comment_escaped = escape_comment (new_comment)
    hash[Time.zone.now.to_s] = {:id => user.id, :name => user.name, :comment => comment_escaped}
    current_comments << hash
    h = {}
    current_comments.each{|i|i.each{|k,v|h[k] = v unless h[k]}}

    self.comments = Array.new

    comments_hash = Array.new
    h.each{|k,v|comments_hash << {k=> v}}

    self.comments = escape_comments(comments_hash)
    # puts "UPDATING VOTES WITH VOTES AFTER ADDING VOTE  #{self.votes.inspect}"
    # self.votes = h
    update_pg_comments(self.comments ,self)

  end


  def escape_comments(h)
    if h and !h.empty?
      h.each do|commnet_hash|
        if commnet_hash
          commnet_hash.each do|key,comment|
            # puts "KEY #{key} CPMMENT #{comment}"
           if (comment && comment["comment"])
             comment_escaped = escape_comment(comment["comment"])
             comment["comment"] = comment_escaped
           end
           commnet_hash[key] = comment
          end
        end
      end

    end
    h
  end


  def new_invitees(invitees )
    self.invitees = invitees
    # hash = Hash.new


    # invitees.each do|invitee|
    #   hash[invitee] = user.id
    # end

    # hash[Time.zone.now.to_s] = {:id => user.id, :name => user.name, :comment => comment}
    # self.invitees << hash
    new_pg_invitees(invitees, self)
  end


  def update_invitees(invitees, current_invitees)
    # puts "UPDATE COMMENT #{current_comments}"
    if !current_invitees
      self.invitees = Array.new
      current_invitees =Array.new
    end

    hash = Hash.new
    invitees.each do|invitee|
      # hash[invitee] = user.id
      current_invitees << invitee
    end

    h = {}
    current_invitees.each{|i|i.each{|k,v|h[k] = v unless h[k]}}

    self.invitees = Array.new

    h.each{|k,v|self.invitees << {k=>v}}
    # puts "UPDATING VOTES WITH VOTES AFTER ADDING VOTE  #{self.votes.inspect}"
    # self.votes = h
    update_pg_invitees(self.invitees ,self)

  end



  def update_info


    # info = info_hash(lactic_session_model)
    update_pg_info(self.lactic_session,self.id)



  end

  def info_hash lactic_session_model
    hash = {}; lactic_session_model.attributes.each { |k,v| hash[k] = v }
    return hash
  end


  def to_lactic_session
    lactic_session = LacticSession.new
    lactic_session.id = self.origin_id
    lactic_session.title = self.lactic_session.title
    lactic_session.description = self.lactic_session.description
    lactic_session.duration = self.lactic_session.duration
    lactic_session.creator_fb_id = self.lactic_session.creator_fb_id
    lactic_session.week_day = self.lactic_session.week_day
    lactic_session.creator_id = self.lactic_session.creator_id
    lactic_session.location = self.lactic_session.location
    lactic_session.location_id = self.lactic_session.location_id
    lactic_session.location_origin = self.lactic_session.location_origin
    lactic_session.instagram_image = self.lactic_session.instagram_image

    lactic_session
  end




  def self.from_hash(session_hash)

    session_replica = nil

    if session_hash
      session_replica = SessionReplica.new
      session_replica.id = session_hash["id"].to_i
      session_replica.start_date = Time.parse(session_hash["start_date"].to_s).to_datetime
      session_replica.origin_id = session_hash["origin_id"].to_i
      session_replica.votes = from_array_json_load(session_hash["votes"])
      session_replica.comments = from_json_load(session_hash["comments"])

      session_replica.invitees = from_json_load(session_hash["invitees"])
      session_replica.info = from_json_load(session_hash["info"])
      session_replica.lactic_session = session_replica.set_session_template

    end
    session_replica
  end


  def set_session_template
    session = LacticSession.new
    session.id = self.origin_id
    session.title = self.info["title"]
    session.description = self.info["description"]
    session.start_date_time = self.info["start_date_time"]
    session.end_date_time = self.info["end_date_time"]
    session.location = self.info["location"]
    session.location_id = self.info["location_id"]
    session.duration = self.info["duration"]
    session.creator_fb_id = self.info["creator_fb_id"]
    session.creator_id = self.info["creator_id"]
    session.location_id = self.info["location_id"]
    session.location = self.info["location"]
    session.location_origin = self.info["location_origin"]
    session.votes = self.votes
    session.comments = self.comments
    session.invitees = self.invitees
    session.instagram_image = self.info["instagram_image"]

    # session.inviter_id = self.info["inviter_id"] || session.creator_id
    # session.inviter_picture = self.info["inviter_picture"] || "https://graph.facebook.com/#{session.inviter_id}/picture?type=large"
    # session.inviter_name = self.info["inviter_name"] || ''

    session
  end

  def self.from_json_load(search_combined)

    json_result = nil

    if search_combined

    first_parse =  search_combined.to_s.gsub('\\\\"', '"')

    first_parse = first_parse.gsub('\\"', '"')
    first_parse = first_parse.gsub('\\\"', '"')
    first_parse = first_parse.gsub('\\\"', '"')

    json_result = (search_combined.to_s.gsub('\"', '"')).to_json
    if (!search_combined ||  search_combined.empty? || search_combined=="{}"|| search_combined=="{[]}" )
      json_result = [{}]
    else
      # puts "PARSING TO JSON #{search_combined.gsub('{"[', '[').gsub(']"}', ']').gsub('\"', '"')}"
      escaped_search_combined = search_combined.gsub('{"[', '[').gsub(']"}', ']').gsub('\"', '"')
      unescape_search_combined = PostgresHelper.unescape_title_descriptions(escaped_search_combined)
      json_result = JSON.parse(unescape_search_combined)
      json_result
    end
    end

    json_result

  end

  def self.from_array_json_load(search_combined)

    json_result = nil

    if search_combined

      first_parse =  search_combined.to_s.gsub('\\\\"', '"')

      first_parse = first_parse.gsub('\\"', '"')
      first_parse = first_parse.gsub('\\\"', '"')
      first_parse = first_parse.gsub('\\\"', '"')

      json_result = (search_combined.to_s.gsub('\"', '"')).to_json
      if (!search_combined ||  search_combined.empty? || search_combined=="{}"|| search_combined=="{[]}" )
        json_result = [{}]
      else
        # puts "PARSING TO JSON #{search_combined.gsub('{"[', '[').gsub(']"}', ']').gsub('\"', '"')}"
        json_result = JSON.parse(search_combined.gsub('{"[', '[').gsub(']"}', ']').gsub('\"', '"'))
        json_result
      end
    end

    json_result

  end



end
