

module PostgresLacticSessions

  include PostgresHelper


  def get_pg_by_uid(creator_fb_id,start_date_time,user_request_id)
    lactic_sessions = []
    start_time = (start_date_time)? start_date_time.utc.strftime('%Y-%m-%d %H:%M:%S.%N'): DateTime.now.strftime('%Y-%m-%d %H:%M:%S.%N')
    result2 = postgres_exec("SELECT * FROM lactic_sessions WHERE creator_fb_id='#{creator_fb_id}' " )
    result2.each do |row|
      lactic_sessions << from_postgres_lactic_session(row,user_request_id)
    end

    lactic_sessions
  end


  def get_pg_by_id(id,user_request_id)
    lactic_session = nil

    if id && id.to_i != 0

      # puts "SELECT * FROM lactic_sessions WHERE id=#{id}"
      result2 = postgres_exec( "SELECT * FROM lactic_sessions WHERE id=#{id}" )
      result2.each do |row|
        lactic_session = from_postgres_lactic_session(row,user_request_id)
      end
    else
      # puts "ERROR! SELECT * FROM lactic_sessions WHERE id=#{id} ID SHOULD BY TYPE NUMBER"
    end

    lactic_session
  end

  def save_pg_new_lactic(lactic_model,user_request_id)

    result = nil
    # result = lactic_model

    if lactic_model

      start_time = (lactic_model.start_date_time)? lactic_model.start_date_time.utc.strftime('%Y-%m-%d %H:%M:%S.%N'): DateTime.now.utc.strftime('%Y-%m-%d %H:%M:%S.%N')
      end_time = (lactic_model.end_date_time)? lactic_model.end_date_time.utc.strftime('%Y-%m-%d %H:%M:%S.%N'):nil
      if end_time
        # puts "INSERT INTO lactic_sessions (created_at,updated_at,start_date_time,end_date_time,title,description,location,location_id,shared,creator_id,creator_fb_id,duration,week_day,type) VALUES (NOW(),NOW(),'#{start_time}','#{end_time}','#{USERS_POSTGRES_CONNECTION.escape_string((lactic_model.title).gsub("'", '%q'))}','#{USERS_POSTGRES_CONNECTION.escape_string((lactic_model.description).gsub("'", '%q'))}','#{USERS_POSTGRES_CONNECTION.escape_string((lactic_model.location).gsub("'", "%q"))}','#{lactic_model.location_id}',#{lactic_model.shared},'#{lactic_model.creator_id}','#{lactic_model.creator_fb_id}',#{lactic_model.duration},#{lactic_model.week_day},#{lactic_model.type}) RETURNING id"

        postgres_result = postgres_exec("INSERT INTO lactic_sessions (created_at,updated_at,start_date_time,end_date_time,title,description,location,location_id,shared,creator_id,creator_fb_id,duration,week_day,type,location_origin) VALUES (NOW(),NOW(),'#{start_time}','#{end_time}','#{USERS_POSTGRES_CONNECTION.escape_string((lactic_model.title).gsub("'", '%q'))}','#{USERS_POSTGRES_CONNECTION.escape_string((lactic_model.description).gsub("'", '%q'))}','#{USERS_POSTGRES_CONNECTION.escape_string((lactic_model.location).gsub("'", "%q"))}','#{lactic_model.location_id}',#{lactic_model.shared},'#{lactic_model.creator_id}','#{lactic_model.creator_fb_id}',#{lactic_model.duration},#{lactic_model.week_day},#{lactic_model.type},'#{lactic_model.location_origin}') RETURNING id")
      else
        # puts "INSERT INTO lactic_sessions (created_at,updated_at,start_date_time,title,description,location,location_id,shared,creator_id,creator_fb_id,duration,week_day,type) VALUES (NOW(),NOW(),'#{start_time}','#{USERS_POSTGRES_CONNECTION.escape_string((lactic_model.title).gsub("'", '%q'))}','#{USERS_POSTGRES_CONNECTION.escape_string((lactic_model.description).gsub("'", '%q'))}','#{USERS_POSTGRES_CONNECTION.escape_string((lactic_model.location).gsub("'", '%q'))}','#{lactic_model.location_id}',#{lactic_model.shared},'#{lactic_model.creator_id}','#{lactic_model.creator_fb_id}',#{lactic_model.duration},#{lactic_model.week_day},#{lactic_model.type}) RETURNING id"
        postgres_result = postgres_exec("INSERT INTO lactic_sessions (created_at,updated_at,start_date_time,title,description,location,location_id,shared,creator_id,creator_fb_id,duration,week_day,type,location_origin) VALUES (NOW(),NOW(),'#{start_time}','#{USERS_POSTGRES_CONNECTION.escape_string((lactic_model.title).gsub("'", '%q'))}','#{USERS_POSTGRES_CONNECTION.escape_string((lactic_model.description).gsub("'", '%q'))}','#{USERS_POSTGRES_CONNECTION.escape_string((lactic_model.location).gsub("'", '%q'))}','#{lactic_model.location_id}',#{lactic_model.shared},'#{lactic_model.creator_id}','#{lactic_model.creator_fb_id}',#{lactic_model.duration},#{lactic_model.week_day},#{lactic_model.type},'#{lactic_model.location_origin}') RETURNING id")
      end

      postgres_result.each do |row|
        if row.values_at('id') && row.values_at('id')[0]
          lactic_model.id = row.values_at('id')[0].to_i

          # puts "PG RETURN ID #{lactic_model.id}"
        end
      end

      result = (postgres_result)? lactic_model : nil

    end
    # puts "PG RETURN RESULT #{result.inspect}"
    result

  end




  def all_pg_between(day1,day2,uid,user_request_id)
    lactic_session = nil

    start_time = (day1)? day1.utc.strftime('%Y-%m-%d %H:%M:%S.%N'):nil
    end_time = (day2)? day2.utc.strftime('%Y-%m-%d %H:%M:%S.%N'): nil
    if start_time && end_time && uid
      result2 = postgres_exec("SELECT * FROM lactic_sessions WHERE creator_fb_id='#{uid}' AND ((start_date_time >= '#{start_time}' AND end_date_time <= '#{end_time}') OR (end_date_time IS NULL AND start_date_time <='#{end_time}'))" )
      lactic_session = Array.new
      result2.each do |row|
        lactic_session << from_postgres_lactic_session(row,user_request_id)
      end
      # lactic_session
    end
    lactic_session
  end



  def delete_pg_session(id, delete_date)

    result = false
    date = (delete_date)? delete_date.utc.strftime('%Y-%m-%d %H:%M:%S.%N'): nil

    if date
      update_result = postgres_exec("UPDATE lactic_sessions SET deleted='true',date_deleted = '#{date}',updated_at=NOW() WHERE id=#{id}")
      result = update_result && update_result.cmd_tuples()!=0
    end
    result
  end


  def from_postgres_lactic_session(postgres_record,user_request_id)
    lactic_session = LacticSession.from_hash(postgres_record,user_request_id)

    lactic_session
  end

end