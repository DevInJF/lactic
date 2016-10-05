

module PostgresSessionReplica

  include PostgresHelper



  def get_pg_replica(origin_id,start_date_time)
    result = nil

    # puts "START TIME REPLICA UTC #{start_date_time.utc.strftime('%Y-%m-%d %H:%M:%S %z')}"
    start_time = (start_date_time)? "#{start_date_time.utc.strftime('%Y-%m-%d %H:%M:%S')}": "#{DateTime.now.utc.strftime('%Y-%m-%d %H:%M:%S')}"

    if origin_id && start_time && origin_id.to_i != 0
      replica = postgres_exec("SELECT * FROM session_replicas WHERE origin_id=#{origin_id} AND start_date='#{start_time}'" )
      if replica
        replica.each do |row|
          result = from_postgres(row)
        end
      end
    end
    # puts "REPLICA FROM POSTGRES #{result.inspect}"
    result
  end



  def save_pg_replica(replica_session)
    result = nil

    start_date = (replica_session.start_date)? "#{replica_session.start_date.utc.strftime('%Y-%m-%d %H:%M:%S')}": "#{DateTime.now.utc.strftime('%Y-%m-%d %H:%M:%S')}"

    if replica_session
      save_result = postgres_exec("INSERT INTO session_replicas (origin_id,start_date,info) VALUES (#{replica_session.origin_id},'#{start_date}',JSON('#{USERS_POSTGRES_CONNECTION.escape_string(replica_session.info)}'])")
      if save_result
        result.each do |row|
          result = from_postgres(row)
        end
      end
    end
    result
  end




  def new_pg_vote(vote,session)
    result = nil
    if vote
      save_result = postgres_exec("INSERT INTO session_replicas (start_date,created_at,updated_at,votes,origin_id,info) VALUES ('#{session.start_date.utc.strftime('%Y-%m-%d %H:%M:%S')}',NOW(),NOW(),ARRAY [JSON('#{USERS_POSTGRES_CONNECTION.escape_string(session.votes.to_json)}')],#{session.origin_id},JSON('#{USERS_POSTGRES_CONNECTION.escape_string(session.lactic_session.to_lactic_json)}'))")
      result =  save_result && save_result.cmd_tuples()!=0
    end
    result

    end

  ### SET NEW REPLICA ROW ON PG FORM LACTIC SESSION MODEL!
  def new_pg_info(session)
    result = nil
    save_result = postgres_exec("INSERT INTO session_replicas (start_date,created_at,updated_at,origin_id,info) VALUES ('#{session.start_date_time.utc.strftime('%Y-%m-%d %H:%M:%S')}',NOW(),NOW(),#{session.id},JSON('#{USERS_POSTGRES_CONNECTION.escape_string(session.to_lactic_json)}'))")
    result =  save_result && save_result.cmd_tuples()!=0

    result

    end

  # def update_replica_pg_info(replica)
  #   result = nil
  #   save_result = postgres_exec("UPDATE session_replicas SET info = JSON('#{USERS_POSTGRES_CONNECTION.escape_string(replica.lactic_session.to_lactic_json)}') WHERE id=#{replica.id}")
  #   result =  save_result && save_result.cmd_tuples()!=0
  #
  #   result
  #
  # end

  def new_pg_invitees(invitees,session)

    result = nil
    if invitees
      save_result = postgres_exec("INSERT INTO session_replicas (start_date,created_at,updated_at,invitees,origin_id,info) VALUES ('#{session.start_date.utc.strftime('%Y-%m-%d %H:%M:%S')}',NOW(),NOW(),ARRAY [JSON('#{USERS_POSTGRES_CONNECTION.escape_string(invitees.to_json)}')],#{session.origin_id},JSON('#{USERS_POSTGRES_CONNECTION.escape_string(session.lactic_session.to_lactic_json)}'))")
      if save_result
        save_result.each do |row|
          result = from_postgres(row)
        end
      end
    end
    result
    end


  def new_pg_comment(comments,session)

    result = nil
    if comments
      save_result = postgres_exec("INSERT INTO session_replicas (start_date,created_at,updated_at,comments,origin_id,info) VALUES ('#{session.start_date.utc.strftime('%Y-%m-%d %H:%M:%S')}',NOW(),NOW(),ARRAY [JSON('#{USERS_POSTGRES_CONNECTION.escape_string(comments.to_json)}')],#{session.origin_id},JSON('#{USERS_POSTGRES_CONNECTION.escape_string(session.lactic_session.to_lactic_json)}'))")
      result =  save_result && save_result.cmd_tuples()!=0
    end
    result
  end


  def update_pg_votes(votes,session)
    result = nil

    # puts "UPDATING VOTES WITH VOTES #{votes.inspect}"
    if votes && session.origin_id && session.origin_id.to_i != 0
        save_result = postgres_exec("UPDATE session_replicas SET votes = ARRAY[JSON('#{USERS_POSTGRES_CONNECTION.escape_string(votes.to_json)}')] WHERE origin_id=#{session.origin_id} AND start_date='#{session.start_date.utc.strftime('%Y-%m-%d %H:%M:%S')}'")

        result =  save_result && save_result.cmd_tuples()!=0
          # save_result.each do |row|
          #   result = from_postgres(row)
          # end



    end
    # puts "RESULT UPDATE VOTE PG #{result.inspect}"
    result
    end
  def update_pg_comments(comments,session)
    result = nil

    # puts "UPDATING COMMENTS POSTGRES #{USERS_POSTGRES_CONNECTION.escape_string(comments).inspect}"
    # puts "UPDATE session_replicas SET comments = ARRAY[JSON('#{comments.to_json}')] WHERE origin_id=#{session.origin_id} AND start_date='#{session.start_date.utc.strftime('%Y-%m-%d %H:%M:%S')}'"
    if comments && session.origin_id && session.origin_id.to_i != 0
        save_result = postgres_exec("UPDATE session_replicas SET comments = ARRAY[JSON('#{USERS_POSTGRES_CONNECTION.escape_string(comments.to_json)}')] WHERE origin_id=#{session.origin_id} AND start_date='#{session.start_date.utc.strftime('%Y-%m-%d %H:%M:%S')}'")
        result =  save_result && save_result.cmd_tuples()!=0

        # if save_result
        #   save_result.each do |row|
        #     result = from_postgres(row)
        #   end
        # end

    end
    # puts "UPDATING COMMENTS POSTGRES RESULT #{result.inspect}"

    result
    end
  def update_pg_invitees(invitees,session)
    result = nil

    # puts "UPDATING COMMENTS POSTGRES #{comments.inspect}"
    # puts "UPDATE session_replicas SET comments = ARRAY[JSON('#{comments.to_json}')] WHERE origin_id=#{session.origin_id} AND start_date='#{session.start_date.utc.strftime('%Y-%m-%d %H:%M:%S')}'"
    if invitees && session.origin_id && session.origin_id.to_i != 0
        save_result = postgres_exec("UPDATE session_replicas SET invitees = ARRAY[JSON('#{USERS_POSTGRES_CONNECTION.escape_string(invitees.to_json)}')] WHERE origin_id=#{session.origin_id} AND start_date='#{session.start_date.utc.strftime('%Y-%m-%d %H:%M:%S')}'")

        if save_result
          save_result.each do |row|
            result = from_postgres(row)
          end
        end

    end
    # puts "UPDATING COMMENTS POSTGRES RESULT #{result.inspect}"

    result
  end
  def update_pg_info(info,id)
    result = nil

    if info && id && id.to_i != 0
      # begin
        # save_result = USERS_POSTGRES_CONNECTION.exec("UPDATE session_replicas SET info = JSON('#{info}') WHERE id=#{id}")
        save_result = postgres_exec("UPDATE session_replicas SET info = JSON('#{USERS_POSTGRES_CONNECTION.escape_string(info.to_lactic_json)}') WHERE id=#{id}")

        if save_result
          save_result.each do |row|
            result = from_postgres(row)
          end
        end
      # rescue PG::Error => err
      #   $stderr.puts "%p while testing connection: %s" % [ err.class, err.message ]
      #   ActiveRecord::Base.connection.reconnect!
      #
      #
      #   puts "RESCUE FROM PG SAVE ERROR CONNECTING ON USERS SESSION #{err.message}"
      #   USERS_POSTGRES_CONNECTION.reset
      #   result = nil
      # end
    end
    result
  end

  def from_postgres(replica_record)
    # puts "REPLICA RETRIEVE FETCHING TO MODEL #{replica_record.inspect}"

    SessionReplica.from_hash(replica_record)
  end



  # def self.postgres_exec(query)
  #
  #   result =  nil
  #
  #   begin
  #     result = USERS_POSTGRES_CONNECTION.exec(query)
  #   rescue PG::Error => err
  #     begin
  #       puts "RESCUE FROM PG POSTGRES EXEC ERROR  query #{query} ===  ERROR ===  #{err.message}"
  #       USERS_POSTGRES_CONNECTION.reset
  #
  #       ActiveRecord::Base.connection.reconnect!
  #     rescue
  #       sleep 10
  #       retry # will retry the reconnect
  #     else
  #       retry # will retry the database_access_here call
  #     end
  #   end
  #   result
  # end
  #



end