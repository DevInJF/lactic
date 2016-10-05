module PostgresFacebook
  # < ActiveRecord::Base

  include PostgresHelper
  def get_pg_facebook(facebook)


    facebook_user = nil

    # begin
      # USERS_POSTGRES_CONNECTION.exec( "SELECT * FROM facebooks WHERE uid='#{facebook.uid}'" ) do |result2|
        result2 = postgres_exec( "SELECT * FROM facebooks WHERE uid='#{facebook.uid}'" )
        if (result2.cmd_tuples()!=0)
          result2.each do |row|
            facebook_user = from_postgres(row)
          end
        end
    #   end
    # rescue PG::Error => err
    #   $stderr.puts "%p while testing connection: %s" % [ err.class, err.message ]
    #
    #   USERS_POSTGRES_CONNECTION.reset
    #   ActiveRecord::Base.connection.reconnect!
    #
    #
    # end

    facebook_user

  end

  def set_pg_facebook(facebook)

    facebook_user = get_pg_facebook(facebook)

    if !facebook_user
      begin
        new_pg_facebook(facebook)
      rescue PG::Error => err
        begin
          puts "RESCUE FROM PG SAVE ERROR FACEBOOK NEW #{err.message}"
          USERS_POSTGRES_CONNECTION.reset

          ActiveRecord::Base.connection.reconnect!
        rescue
          sleep 10
          retry # will retry the reconnect
        else
          retry # will retry the database_access_here call
        end
      end
    else
      begin
        update_pg_facebook(facebook)
      rescue PG::Error => err
        begin
          USERS_POSTGRES_CONNECTION.reset

          puts "RESCUE FROM PG SAVE ERROR FACEBOOK UPDATE  #{err.message}"
          ActiveRecord::Base.connection.reconnect!
        rescue
          sleep 10
          retry # will retry the reconnect
        else
          retry # will retry the database_access_here call
        end
      end
    end



    # (!facebook_user)? new_facebook(facebook) :update_facebook(facebook)

  end




  def update_pg_facebook(facebook)
    result = nil
    # begin
      puts "UPDATE facebooks SET access_token='#{facebook.access_token}', access_token_expiration_date = '#{facebook.access_token_expiration_date.strftime('%Y-%m-%d %H:%M:%S.%N')}', updated_at = NOW() WHERE uid = '#{facebook.uid}'"




      sql = " WITH upsert AS (UPDATE facebooks  SET access_token='#{facebook.access_token}', access_token_expiration_date = '#{facebook.access_token_expiration_date.strftime('%Y-%m-%d %H:%M:%S.%N')}', updated_at = NOW() WHERE uid = '#{facebook.uid}'  RETURNING *)
          INSERT INTO facebooks (uid,access_token,access_token_expiration_date,created_at,updated_at)
      SELECT  '#{facebook.uid}','#{facebook.access_token}','#{facebook.access_token_expiration_date.strftime('%Y-%m-%d %H:%M:%S.%N')}',NOW(),NOW() WHERE NOT EXISTS (SELECT * FROM upsert);"


      # postgres_result = postgres_exec("UPDATE facebooks SET access_token='#{facebook.access_token}', access_token_expiration_date = '#{facebook.access_token_expiration_date.strftime('%Y-%m-%d %H:%M:%S.%N')}', updated_at = NOW() WHERE uid = '#{facebook.uid}'")
      # puts "UPDATE FACEBOOK DB POSTGRES "

      postgres_result = postgres_exec(sql);
      result = ( postgres_result)? facebook : nil

    puts "POSTGRES USER FACEBOOK UPADTED RESULT #{result.inspect}"
        # postgres_result.each do |row|
      #   result = from_postgres(row)
      # end
    # rescue PG::Error => err
    #   $stderr.puts "%p while testing connection: %s" % [ err.class, err.message ]
      # ActiveRecord::Base.connection.reconnect!

      # puts "RESCUE FROM PG SAVE ERROR CONNECTING ON SAVE FETCHED #{err.message}"
      # USERS_POSTGRES_CONNECTION.reset
    # end
    result

  end


  def new_pg_facebook(facebook)
    result = nil
    result =  update_pg_facebook(facebook)
    result
    #   fb = get_pg_facebook(facebook)
    #   if fb
    #     result = update_pg_facebook(facebook)
    #   else
    #
    #
    #
    #   postgres_result =postgres_exec("INSERT INTO facebooks (uid,access_token,access_token_expiration_date,created_at,updated_at) VALUES ('#{facebook.uid}','#{facebook.access_token}','#{facebook.access_token_expiration_date.strftime('%Y-%m-%d %H:%M:%S.%N')}',NOW(),NOW())")
    #   if  postgres_result.cmd_tuples()!=0
    #     result = facebook
    #   end
    #
    #     # postgres_result.each do |row|
    #   #   result = from_postgres(row)
    #   # end
    # # rescue PG::Error => err
    # #   $stderr.puts "%p while testing connection: %s" % [ err.class, err.message ]
    # #   ActiveRecord::Base.connection.reconnect!
    #
    #   # puts "RESCUE FROM PG SAVE ERROR CONNECTING ON facebooks #{err.message}"
    #   # USERS_POSTGRES_CONNECTION.reset
    # end
    #
    # result
  end



  def koala(auth)
    # puts auth.inspect
    access_token = auth['token']
    facebook = Koala::Facebook::API.new(access_token)
    facebook.get_object("me?fields=name,picture,email")

  end



  def from_postgres(postgres_facebook)

    facebook = nil

    if postgres_facebook

      facebook = Facebook.new
      facebook.uid = postgres_facebook["uid"]
      facebook.id = postgres_facebook["id"].to_i
      facebook.access_token = postgres_facebook["access_token"]
      facebook.access_token_expiration_date = postgres_facebook["access_token_expiration_date"].to_datetime
      facebook.created_at = postgres_facebook["created_at"].to_datetime
      facebook.updated_at = postgres_facebook["updated_at"].to_datetime

    end

    facebook
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