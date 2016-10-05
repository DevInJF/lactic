

module PostgresLacticMatch
  include PostgresHelper
  def create_pg_lactic_request(lactic_request,include_users_record)
    result = nil


    if lactic_request
          result2 = postgres_exec("SELECT * FROM lactic_matches WHERE requestor='#{lactic_request.requestor}' AND responder='#{lactic_request.responder}' AND expires_at >  NOW()" )
          # puts "BEFORE SAVE QUERY #{result2.inspect}"
          if !result2 || result2.cmd_tuples()==0
           postgres_result = postgres_exec("INSERT INTO lactic_matches (requestor,responder,status,expires_at,created_at,updated_at) VALUES ('#{lactic_request.requestor}','#{lactic_request.responder}','#{lactic_request.status}','#{lactic_request.expires_at}',NOW(),NOW())")

           result = (postgres_result && postgres_result.cmd_tuples()!=0) ? lactic_request : nil
            # postgres_result.each do |row|
            #   result = from_postgres(row,include_users_record)
            # end
          else

            result2.each do |row|
              result = from_postgres(row,include_users_record)
              result.request_made = true
            end

          end
    end
    result
  end


  def update_pg_request_status(lactic_request)



  end


  def request_pg_sent(lactic_request,include_users_record)
    result = nil
    if lactic_request
        # puts "SELECT * FROM lactic_matches WHERE requestor='#{lactic_request.requestor}' AND responder='#{lactic_request.responder}' AND expires_at >  NOW()"
        result2 = postgres_exec("SELECT * FROM lactic_matches WHERE requestor='#{lactic_request.requestor}' AND responder='#{lactic_request.responder}' AND expires_at >  NOW()" )
          # puts "BEFORE SAVE QUERY #{result2.inspect}"
          # puts "BEFORE SAVE QUERY MATCHED LOOKUP ==== #{lactic_request.inspect}"
          if !result2 || result2.cmd_tuples()==0

          else
              result2.each do |row|
                result = from_postgres(row,include_users_record)
                result.request_made = true
              end
          end
    end

    result
  end


  def get_pg_user_pending_requests(user_uid,include_users_record)

    lactic_requests_array = nil
    if user_uid
           result2 = postgres_exec("SELECT * FROM lactic_matches WHERE status='pending' AND responder='#{user_uid}' AND expires_at >  NOW()" )
           if result2 && result2.cmd_tuples()!=0
           lactic_requests_array = []
          result2.each do |row|
            lactic_match = from_postgres(row,include_users_record)
            lactic_requests_array << lactic_match
          end
          end

    end
    lactic_requests_array

  end
  def get_pg_user_pending_requests(user_uid,include_users_record)

    lactic_requests_array = nil
    if user_uid
      result2 = postgres_exec("SELECT * FROM lactic_matches WHERE status='pending' AND responder='#{user_uid}' AND expires_at >  NOW()" )
      lactic_requests_array = []
      if result2 && result2.cmd_tuples()!=0
        result2.each do |row|
          lactic_match = from_postgres(row,include_users_record)
          lactic_requests_array << lactic_match
        end
      end

    end
    lactic_requests_array

  end

  def get_pg_user_match(lactic_model)

    result = nil


      result2 = postgres_exec("SELECT * FROM lactic_matches WHERE (responder='#{lactic_model.responder}' AND  requestor='#{lactic_model.requestor}) AND status =''#{lactic_model.status}' AND expires_at > NOW()" )

      if result2 && result2.cmd_tuples()!=0
          result2.each do |row|
            result = from_postgres(row,true)
          end
      end


    result

  end


  def from_postgres(postgres_lactic_match_record,include_users_record)

    lactic_match = nil

    # puts "FROM POSTGRES RECORD #{postgres_lactic_match_record}"

    if postgres_lactic_match_record

        lactic_match = LacticMatch.new
        lactic_match.requestor = postgres_lactic_match_record['requestor']
        lactic_match.responder = postgres_lactic_match_record['responder']
        lactic_match.expires_at = postgres_lactic_match_record['expires_at'].to_datetime
        lactic_match.created_at = postgres_lactic_match_record['created_at'].to_datetime
        lactic_match.status = postgres_lactic_match_record['status']
        lactic_match.id = postgres_lactic_match_record['id'].to_i

        lactic_match = (include_users_record)? set_pg_user_match_from_request(lactic_match):lactic_match

    end

    # puts "FROM POSTGRES MODEL RETURNED  #{lactic_match.inspect}"

    lactic_match

  end


  def update_pg_request_status(lactic_request)
    result = nil
    if lactic_request
             result2 = postgres_exec("SELECT * FROM lactic_matches WHERE id=#{lactic_request.id} " )

            if !result2 || result2.cmd_tuples()==0

            else

              result3 = postgres_exec("UPDATE lactic_matches SET status='#{lactic_request.status}' WHERE id=#{lactic_request.id}")

              if (result3 && result3.cmd_tuples()!=0)
                result2.each do |row|
                  result = from_postgres(row,true)
                end
                result.status = lactic_request.status
              end
            end
        end
    result
  end


  def set_pg_user_match_from_request (lactic_match)

    if lactic_match
      lactic_match.responder_user = UsersController.get_osm_users_by_fbId(lactic_match.responder)
      lactic_match.responder_uid = lactic_match.responder
      lactic_match.responder_name = (lactic_match.responder_user)? lactic_match.responder_user.name : ''
      lactic_match.requestor_user = UsersController.get_osm_users_by_fbId(lactic_match.requestor)
      lactic_match.requestor_uid = lactic_match.requestor
      lactic_match.requestor_name = (lactic_match.requestor_user)? lactic_match.requestor_user.name : ''

    end
    lactic_match

  end



  # def self.postgres_exec(query)
  #
  #   result =  nil
  #
  #   begin
  #     result = USERS_POSTGRES_CONNECTION.exec(query)
  #   rescue PG::Error => err
  #     begin
  #       puts "RESCUE FROM PG POSTGRES EXEC ERROR FACEBOOK query #{query} ===  ERROR ===  #{err.message}"
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
  #
  #
  #   result
  # end







end