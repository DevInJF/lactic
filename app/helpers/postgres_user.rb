module PostgresUser

  include PostgresHelper

  def is_pg_user_by_fb_id(uid)

    user = nil
    result2 = postgres_exec( "SELECT * FROM users WHERE uid='#{uid}'" )
    if (result2.cmd_tuples()!=0)
      result2.each do |row|
        user = from_postgres_user(row,false)
      end
    end
    user
  end

  def is_pg_user_by_email(email)

    user = nil
    result2 = postgres_exec( "SELECT * FROM users WHERE email='#{email}'" )
    if (result2.cmd_tuples()!=0)
      result2.each do |row|
        user = from_postgres_user(row,false)
      end
    end
    user
  end


  def update_pg_name(user)
    id = user.id
    name = user.name

    result = false
    if id && name && !name.empty?
      result = postgres_exec("UPDATE users SET name='#{name}' WHERE id=#{id}")
    end
    result = (!result || result.cmd_tuples()==0)? false : true

  end



  def updatePGGoggleToken(id,token)

  result = false
  if id && token
    result = postgres_exec("UPDATE users SET google_token='#{token}' update_at = NOW()  WHERE id=#{id}")
  end
  result = (!result || result.cmd_tuples()==0)? false : true

  end

  def update_pg_user(user)
    user_updated = nil
    if user



      sql = " WITH upsert AS (UPDATE users SET name='#{USERS_POSTGRES_CONNECTION.escape_string(user.name)}',access_token='#{user.access_token}',access_token_expiration_date='#{user.access_token_expiration_date.strftime('%Y-%m-%d %H:%M:%S.%N')}',email='#{user.email}',user_info='#{USERS_POSTGRES_CONNECTION.escape_string(user.user_info)}',matched=#{user.matched},matched_user='#{user.matched_user}',updated_at=NOW() WHERE id=#{user.id}  RETURNING *)
          INSERT INTO users (id,uid,name,access_token,access_token_expiration_date,email,picture,user_info,matched,matched_user,created_at,updated_at)
SELECT #{user.id},'#{user.uid}','#{USERS_POSTGRES_CONNECTION.escape_string(user.name)}','#{user.access_token}','#{user.access_token_expiration_date}','#{user.email}','#{user.picture}','#{USERS_POSTGRES_CONNECTION.escape_string(user.user_info)}','#{user.matched}','#{user.matched_user}',NOW(),NOW() WHERE NOT EXISTS (SELECT * FROM upsert);"

 puts " WITH upsert AS (UPDATE users SET name='#{USERS_POSTGRES_CONNECTION.escape_string(user.name)}',access_token='#{user.access_token}',access_token_expiration_date='#{user.access_token_expiration_date.strftime('%Y-%m-%d %H:%M:%S.%N')}',email='#{user.email}',user_info='#{USERS_POSTGRES_CONNECTION.escape_string(user.user_info)}',matched=#{user.matched},matched_user='#{user.matched_user}',updated_at=NOW() WHERE id=#{user.id}  RETURNING *)
          INSERT INTO users (id,uid,name,access_token,access_token_expiration_date,email,picture,user_info,matched,matched_user,created_at,updated_at)
SELECT #{user.id},'#{user.uid}','#{USERS_POSTGRES_CONNECTION.escape_string(user.name)}','#{user.access_token}','#{user.access_token_expiration_date}','#{user.email}','#{user.picture}','#{USERS_POSTGRES_CONNECTION.escape_string(user.user_info)}','#{user.matched}','#{user.matched_user}',NOW(),NOW() WHERE NOT EXISTS (SELECT * FROM upsert);"





      # result = postgres_exec("UPDATE users SET name='#{USERS_POSTGRES_CONNECTION.escape_string(user.name)}',access_token='#{user.access_token}',access_token_expiration_date='#{user.access_token_expiration_date.strftime('%Y-%m-%d %H:%M:%S.%N')}',email='#{user.email}',user_info='#{USERS_POSTGRES_CONNECTION.escape_string(user.user_info)}',matched=#{user.matched},matched_user='#{user.matched_user}',updated_at=NOW() WHERE id=#{user.id}")
      result = postgres_exec(sql)
      puts "RESULT #{result.inspect}"
      result.each do |row|
          user_updated = from_postgres_user(row,false)
      end
      user_updated = (user_updated && user_updated.uid && !user_updated.uid.empty?)? user_updated : (result && result.cmd_tuples()!=0)? user : nil
    end
    user_updated
  end

  def update_pg_google_fb_user(user)
    user_updated = nil
    if user
      result = postgres_exec("UPDATE users SET uid='#{(user.uid)}',access_token='#{user.access_token}',access_token_expiration_date='#{user.access_token_expiration_date.strftime('%Y-%m-%d %H:%M:%S.%N')}',updated_at=NOW() WHERE id=#{user.id}")
      result.each do |row|
          user_updated = from_postgres_user(row,false)
      end
    end
    user_updated
  end


  def valid_id(id)
    id && id.to_i && id !=0
  end
  def save_new_pg_user(user)
    # result = nil
    # if user && valid_id(user.id)
    #  postgres_result = postgres_exec("INSERT INTO users (id,uid,name,access_token,access_token_expiration_date,email,picture,user_info,matched,matched_user,created_at,updated_at) VALUES (#{user.id},'#{user.uid}','#{USERS_POSTGRES_CONNECTION.escape_string(user.name)}','#{user.access_token}','#{user.access_token_expiration_date}','#{user.email}','#{user.picture}','#{USERS_POSTGRES_CONNECTION.escape_string(user.user_info)}','#{user.matched}','#{user.matched_user}',NOW(),NOW())")
    #  result =  postgres_result.cmd_tuples()!=0
    # end
    # puts "saved new user pg"
    #   result
    #
    update_pg_user(user)

  end

  def save_new_pg_google_user(user)
    result = nil
    if user
     # puts "INSERT INTO users (id,name,email,picture,google_id,google_token,created_at,updated_at) VALUES (#{user.id},'#{USERS_POSTGRES_CONNECTION.escape_string(user.name)}','#{user.email}','#{user.picture}','#{user.google_id}','#{user.google_token}',NOW(),NOW())"
     postgres_result = postgres_exec("INSERT INTO users (id,name,email,picture,google_id,google_token,created_at,updated_at) VALUES (#{user.id},'#{USERS_POSTGRES_CONNECTION.escape_string(user.name)}','#{user.email}','#{user.picture}','#{user.google_id}','#{user.google_token}',NOW(),NOW())")
     result =  (postgres_result.cmd_tuples()!=0)? user : nil
    end

    result

  end


  def get_pg_user_by_id(user_id,include_match_user_record)
    user = nil
    if user_id
      # puts "SELECT * FROM users WHERE id=#{user_id}"
      result2 = postgres_exec("SELECT * FROM users WHERE id=#{user_id}")
      result2.each do |row|
        user = from_postgres_user(row,include_match_user_record)
      end
    end
    # puts "USER BY ID #{user.inspect}"
    user
  end




  def get_all_pg_lactic_users(email)
    users = nil
    contacts = postgres_exec( "SELECT * FROM users" )
    if contacts
      users = Array.new
      contacts.each do |row|
        if (row.values_at('email') !=  email )
          users << from_postgres_user(row,true)
        end
      end
    end
    users
  end



  def get_pg_users_by_fb_ids(users_ids,include_match_user_record)
    users = []
    if users_ids
      contacts = postgres_exec( "SELECT * FROM users WHERE WHERE uid = ANY(ARRAY[#{users_ids}])" )
      contacts.each do |row|
        users << from_postgres_user(row,include_match_user_record)
      end
    end
    users
  end

  def get_pg_user_by_fbID(fbID,include_match_user_record)
    user = nil
    if fbID
      result2 = postgres_exec("SELECT * FROM users WHERE uid='#{fbID}'")

      if result2
        result2.each do |row|
        user = (row)? from_postgres_user(row,include_match_user_record):user

        end
      end
    end
    user
    end


  def get_pg_user_by_email(email)
    user = nil
    if email
      result2 = postgres_exec("SELECT * FROM users WHERE email='#{email}'")

      if result2
        result2.each do |row|
        user = (row)? from_postgres_user(row,false):user

        end
      end
    end
    user
  end

  def lacticate_pg_users(user,match)
    result = nil
    if match && user
     result = postgres_exec("UPDATE users SET matched=true WHERE id IN (#{user},#{match})")
     result = (result.cmd_tuples()!=0)? postgres_exec("UPDATE users SET matched_user='#{user}' WHERE id='#{match}'"): result
     result = (result.cmd_tuples()!=0)? postgres_exec("UPDATE users SET matched_user='#{match}' WHERE id='#{user}'"): result
    end
    result = (result.nil? || result.cmd_tuples()==0)? nil : true
  end


  def update_pg_google_user(user)
    result = nil
    if user && user.email

     # puts "UPDATE users SET google_id='#{user.google_id}',google_token='#{user.google_token}',picture='#{user.picture}',updated_at=NOW() WHERE email ='#{user.email}'"
     result = postgres_exec("UPDATE users SET google_id='#{user.google_id}',google_token='#{user.google_token}',picture='#{user.picture}',updated_at=NOW() WHERE email ='#{user.email}'")
    end
    (result.nil? || result.cmd_tuples()==0)? nil : user

  end




  def lactic_pg_contacts(uid,lactic_contacts)

    result = {}
    if uid
     contacts = postgres_exec("SELECT * FROM contacts_retrieves WHERE uid='#{uid}' AND lactic_contacts=#{lactic_contacts}" )
         if contacts
            contacts.each do |row|
              result = row.values_at('last_fetch')
            end
          end
    end
    result
  end


  def hashed_pg_fb_contacts(uid)
    result = {}
    if uid
      contacts = postgres_exec("SELECT * FROM contacts_retrieves WHERE uid='#{uid}' AND lactic_contacts='false'" )
      if contacts
        contacts.each do |row|
          result = row.values_at('hashed_fb_contacts')
        end
      end
    end
    result
  end



  def save_pg_fb_hashed_contacts(uid,hashed_fb_contacts)
    result = []
    if uid && hashed_fb_contacts && !(hashed_fb_contacts.empty?)
      result2 = postgres_exec("SELECT hashed_fb_contacts FROM contacts_retrieves WHERE uid='#{uid}' AND lactic_contacts=false" )
      if !result2 || result2.cmd_tuples()==0
        result = postgres_exec("INSERT INTO contacts_retrieves (uid,hashed_fb_contacts,lactic_contacts) VALUES ('#{uid}',ARRAY[JSON ('#{USERS_POSTGRES_CONNECTION.escape_string(hashed_fb_contacts)}')],'false')")
      else
        result = postgres_exec("UPDATE contacts_retrieves SET hashed_fb_contacts=ARRAY[JSON ('#{USERS_POSTGRES_CONNECTION.escape_string(hashed_fb_contacts)}')] WHERE uid='#{uid}' AND lactic_contacts='false'")
      end
    end
    result
  end


  def save_pg_contacts_retrieve(uid,contacts,lactic_contacts)
    result = []
    if uid && contacts && !contacts.empty?
      result2 = postgres_exec("SELECT last_fetch FROM contacts_retrieves WHERE uid='#{uid}' AND lactic_contacts=#{lactic_contacts}" )
      if !result2 || result2.cmd_tuples()==0
        result =postgres_exec("INSERT INTO contacts_retrieves (uid, last_fetch,lactic_contacts) VALUES ('#{uid}',ARRAY[JSON ('#{USERS_POSTGRES_CONNECTION.escape_string(contacts)}')],#{lactic_contacts})")
      else
        result = postgres_exec("UPDATE contacts_retrieves SET last_fetch=ARRAY[JSON ('#{USERS_POSTGRES_CONNECTION.escape_string(contacts)}')] WHERE uid='#{uid}' AND lactic_contacts='#{lactic_contacts}'")
      end
    end
    # end
    result
  end



  def from_postgres_user(user_postgres_record,include_match_user_record)

    user = nil
    if user_postgres_record

      user = User.new
      user.uid = user_postgres_record['uid'] || ''
      if user_postgres_record['name'] == 'Birnbaum Ze"evik' || user_postgres_record['uid'] == '10153963337906492'
        # puts "ZEEVIK NAME ON PG #{user_postgres_record['name']}"
        user_postgres_record['name'] = 'Birnbaum Ze%qevik'
      end
      user.name = PostgresHelper.unescape_title_descriptions(user_postgres_record['name'])
      user.access_token = user_postgres_record['access_token']
      user.access_token_expiration_date = (user_postgres_record['access_token_expiration_date'])?user_postgres_record['access_token_expiration_date'].to_datetime : DateTime.now

      user.email = user_postgres_record['email']
      user.picture = user_postgres_record['picture']? (user_postgres_record['picture']).gsub('httpsss','https') : "https://graph.facebook.com/#{user.uid}/picture?type=large"
      user.user_info = user_postgres_record['user_info']
      user.matched = user_postgres_record['matched']
      user.matched_user = (user_postgres_record['matched_user'])? user_postgres_record['matched_user'] : ''
      user.id = user_postgres_record['id'].to_i
      user.google_token = user_postgres_record['google_token']

      user.matched_user_model = (include_match_user_record)? set_user_match_model_from_record(user):nil

    end
    user

  end


  def set_user_match_model_from_record(user)
    user_matched_included = nil

    if user && user.matched && user.matched_user
      # puts "INCLUDING MATCHED....."
      user_matched_included = get_user_by_id(user.matched_user,false)
    end

    user_matched_included
  end



  def global_pg_weekly_unmatch_lactic
    result = postgres_exec('UPDATE users SET matched=false')
    result && result.cmd_tuples()!=0
  end







end