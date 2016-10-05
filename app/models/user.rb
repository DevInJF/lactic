class User < ActiveRecord::Base
  attr_accessor :search_user_name

  attr_accessor :follows, :osm_id, :avatar_file
  attr_accessor :matched_user_model, :matched_picture
  attr_accessor :matched_record_id
  attr_accessor :user_info_model, :current_keywords
  attr_accessor :title, :location, :website, :filtered
  attr_accessor :keyword
  attr_accessor :last_lat, :last_longt



  include PostgresUser
  include PostgresUserInfos
  include PostgresEngineSearches
  include PostgresHelper
  # mount_uploader :avatar, AvatarUploader

  def self.koala(auth)
    # puts auth.inspect
    access_token = auth['token']
    facebook = Koala::Facebook::API.new(access_token)
    facebook.get_object("me?fields=name,picture,email")
  end


#<OmniAuth::AuthHash
# credentials=#<OmniAuth::AuthHash expires=true expires_at=1437951604
              #token="CAAU0TyH3ueMBAKaWJD26SvTHbkByRMQC1EQy5FQsrxuyq9XncibgyyPjb6R4VDXeUAbrUWe6aB2LgmLWgWBojZA2HgNZArqJqRkZCXeTrGfFW8LvWSqLGHTtDwpnGZCcbZC4wgZAT3q5YzmCIYQS0tfL0E6h70KTL1dBsrvy5MPXwnKBwmMsaZArzvvurAAnJk7Qsa59PzMo9aVvJbNGCVA">
# extra=#<OmniAuth::AuthHash
        # raw_info=#<OmniAuth::AuthHash
                    # id="10153011850791938"
                    # name="Sharon Nachum">>
        # info=#<OmniAuth::AuthHash::InfoHash
        #           image="http://graph.facebook.com/10153011850791938/picture"
                    #name="Sharon Nachum"> provider="facebook" uid="10153011850791938">
  def self.from_omniauth(auth,email,picture_url)

    # puts "USER PICTURE #{[picture_url]}"
      user =  User.new
      # user.provider = auth['provider']
      user.uid = auth.uid
      user.id = user.uid.to_i
      user.name = auth['info']['name']
      user.email = email
      user.picture = picture_url
      user.access_token = auth['credentials']['token']

      # if (auth['credentials']['expires_at'])
      user.access_token_expiration_date = Time.at(auth['credentials']['expires_at']) unless auth['credentials']['expires_at'].nil?

      user.access_token_expiration_date ||= Time.at(DateTime.now)
      # user.save!
    user


  end

  def update_user
   # PostgresUser.update_user(self)
    update_pg_user(self)
  end


  def update_google_token(uid, token)
    if uid && token
      updatePGGoggleToken(uid.to_i,token)
    end
  end
  def update_user(user)
   # PostgresUser.update_user(user)
  update_pg_user(user)
  end


  # def self.link_user_info(user_info)
  #
  #   result = nil
  #   user = User.new
  #   user.id = user_info.uid.to_i
  #   if user_info.uid && user_info.id
  #     user.user_info = user_info.id
  #     result = update_pg_user
  #   end
  #   result
  #
  # end


  ## Update the users table with the matched partners
  ## Return true if lacticate users was successful and nil otherwise
  def lacticate_users(user1,user2)
    # PostgresUser.lacticate_users(user1,user2)
    lacticate_pg_users(user1,user2)
  end

  ## Return the last_fetched user's contacts (lactic or other)
  def lactic_contacts(id,lactic_contacts)
    # PostgresUser.lactic_contacts(uid,lactic_contacts)
    lactic_pg_contacts(id,lactic_contacts)
  end


  def get_hashed_fb_friends
    # PostgresUser.hashed_fb_contacts(self.uid)
    hashed_pg_fb_contacts(self.uid)
  end

  def save_contacts_retrieve(uid,facebook_friends,lactic_contacts)
    # PostgresUser.save_contacts_retrieve(uid,facebook_friends,lactic_contacts)
    save_pg_contacts_retrieve(uid,facebook_friends,lactic_contacts)
  end

  def save_fb_hashed_contacts(uid,facebook_friends_json)
    # PostgresUser.save_fb_hashed_contacts(uid,facebook_friends_json)
    save_pg_fb_hashed_contacts(uid,facebook_friends_json)
  end

  def user_to_json_string(contacts_users)
    contacts_json = ''
    contacts_users.each do |user|
      if user.name == 'Birnbaum Ze"evik' || user.uid == '10153963337906492'
        user.name = 'Birnbaum Ze%qevik'
      end
      contacts_json.concat("{'name' : '#{user.name}','id' : '#{user.uid}', 'picture' : '#{(user.picture).gsub("\\\\\\\\u0026", '&').gsub("\\\\u0026", '&')}'},".gsub("'", '"'))
    end
    contacts_json = '[' + contacts_json + ']'
    contacts_json = contacts_json.gsub(',]', ']')
    contacts_json
  end


  def hashed_json_contacts_to_json_string(search,id)
    search_json = {}
    if (search)
      search.each do |search_item|

        string  = search_item.to_s.gsub('\"', '"').gsub(']"}', ']').gsub('{"[', '[')
        string = string.gsub('\"', '"')
        arr_hash = JSON.parse(string)

        Hash hash = Hash.new

        arr_hash.each do |contact|

          hash[contact.keys[0]] = contact.values[0]
          search_json = (hash[contact.keys[0]] == id)? contact.values[0] :search_json
        end
        fetch = hash.fetch(id,{})
        search_json = fetch
      end

    end

   search_json


  end



  def new_save_from_user(user)

    puts "NEW SAVE FROM USER #{user.inspect}"
    if user && user.email && user.access_token && user.access_token_expiration_date
      expiration_date = DateTime.parse(user.access_token_expiration_date.to_s) || DateTime.now
      ### Check if user already a user on Postgres DB
      # postgres_user = PostgresUser.is_user_by_fb_id(user.uid)
      # postgres_user = is_pg_user_by_fb_id(user.uid)
      postgres_user = is_pg_user_by_email(user.email)
      if (postgres_user && postgres_user.uid && !postgres_user.uid.empty?)
        if ( postgres_user.access_token_expiration_date > Date.today)
          ### no updates needed.
          puts "NEW SAVE FROM USER - NO UPDATES NEEDED"
          postgres_user
        else
          #### Update user with new auth
          postgres_user.access_token = user.access_token
          postgres_user.access_token_expiration_date = expiration_date
          # PostgresUser.update_user(postgres_user)
          puts "NEW SAVE FROM USER - UPDATES NEEDED!!!!"
          update_pg_user(postgres_user)
        end
      else
        if postgres_user && postgres_user.google_id
          puts "NEW SAVE FROM USER - NEW GOOGLE PG SAVE "
          ## update google user
          postgres_user.uid = user.uid
          postgres_user.access_token = user.access_token
          postgres_user.access_token_expiration_date = expiration_date

          update_pg_google_fb_user(postgres_user)

        else
          puts "NEW SAVE FROM USER - NEW USER PG SAVE "
          postgres_user = User.new
          ## NEW USER...
          postgres_user.uid = user.uid
          postgres_user.id = user.uid.to_i
          postgres_user.email = user.email
          postgres_user.name = PostgresHelper.escape_title_descriptions(user.name)
          postgres_user.picture = "https://graph.facebook.com/#{user.uid}/picture?type=large"
          postgres_user.matched = false
          postgres_user.matched_user = ''
          postgres_user.user_info = ''
          postgres_user.access_token = user.access_token
          postgres_user.access_token_expiration_date = expiration_date
          puts "SAVE NEW USER"

          save_new_pg_user(postgres_user)

        end



        # PostgresUser.save_new_user(postgres_user)

      end
    else

    end
  end


  def update_google_user
    update_pg_google_user(self)
  end


  def save_google_user
    save_new_pg_google_user(self)
  end


  def get_user_by_fbID(fbID, include_match_user_record)
    # puts "get FB ID METHOD CALLER #{caller[0].split("`").pop.gsub("'", "")}"
   # PostgresUser.get_user_by_fbID(fbID,include_match_user_record)
   get_pg_user_by_fbID(fbID,include_match_user_record)

   end
  def get_user_by_id(id, include_match_user_record)
    # puts "get FB ID METHOD CALLER #{caller[0].split("`").pop.gsub("'", "")}"
   # PostgresUser.get_user_by_fbID(fbID,include_match_user_record)
   get_pg_user_by_id(id,include_match_user_record)

  end

  def get_user_by_email
    # puts "get FB ID METHOD CALLER #{caller[0].split("`").pop.gsub("'", "")}"
   # PostgresUser.get_user_by_fbID(fbID,include_match_user_record)
   get_pg_user_by_email(self.email)
  end

  def get_users_by_fb_ids(users_ids,include_match_user_record)
    # PostgresUser.get_users_by_fb_ids(users_ids,include_match_user_record)
    get_pg_users_by_fb_ids(users_ids,include_match_user_record)
  end


  def all_lactic_users(email)
      # all = PostgresUser.get_lactic_users(uid)
      all = get_all_pg_lactic_users(email)
      user_to_json_string(all)
  end


  def set_title (title)
    # PostgresUserInfos.save_title(title,self.id)
    # save_pg_user_info_title(title,self.id)
  end

  def set_locations (locations)
    # PostgresUserInfos.save_locations(locations,self.id)
    # save_pg_locations(locations,self.id)
  end


  def self.from_postgres_user_info(postgres_user_info)
    user = UserInfo.new
    # puts "FROM POSTGRES INFO #{postgres_user_info.inspect}"
    if postgres_user_info

      user.id = postgres_user_info['id'] || ''
      user.title = postgres_user_info['title'] || ''
      user.about = postgres_user_info['about'] || ''
      user.locations = (postgres_user_info['locations'] && postgres_user_info['locations'] != '{}')? PostgresUserInfos.from_json_load( postgres_user_info['locations']) : Array.new

    end
    # puts "FROM POSTGRES INFO result #{user.inspect}"

    user

  end



  def users_by_keyword(keyword)

    users =   Array.new

    if UsersHelper.is_valid_keyword(keyword)
      # users = PostgresEngineSearches.get_keyword_users(keyword)
      users = get_pg_keyword_users(keyword)
    end

    users

  end
  def users_by_keywords(keywords)

    users =   Hash.new
    valid_keywords =  UsersHelper.get_valid_keywords(keywords)

    if valid_keywords && !valid_keywords.empty?
      # users = PostgresEngineSearches.get_keywords_users(keywords)
      users = get_pg_keywords_users(keywords)
    end

    users

    end
  def users_by_keywords_ids(keywords)

    users =   Array.new
    valid_keywords =  UsersHelper.get_valid_keywords(keywords)

    if valid_keywords && !valid_keywords.empty?
      # users = PostgresEngineSearches.get_keywords_users_ids(keywords)
      users = get_pg_keywords_users_ids(keywords)
    end

    users

  end


  def add_user_keyword(keyword)
    result = nil
    if UsersHelper.is_valid_keyword(keyword)

      users = users_by_keyword(keyword)

      hash = Hash.new
      hash[self.id.to_s] = self.name
      users << hash
      h = {}
      user_in = false
      users.each{|i|i.each do|k,v|
        user_in ||=  h[k]
        h[k] = v
      end
      }
      # puts "USERS  #{users.inspect}"
      users_updated = Array.new

      h.each{|k,v|users_updated << {k=>v}}

      # puts "USERS UPDATED #{users_updated.inspect}"
      # user_in = users[self.uid]
      # users[self.uid] = self.name
      # result = (!user_in) ? PostgresEngineSearches.update_keyword_users(users_updated,keyword) : true
      result = (!user_in) ? update_pg_keyword_users(users_updated,keyword) : true
    end
    result
  end

  def update_name(user_info)
    self.id = user_info.id
    self.name = user_info.name
    # PostgresUser.update_name(self)
    update_pg_name(self)
  end

  def remove_user_keyword(keyword)
    result = false
    if UsersHelper.is_valid_keyword(keyword)
      users = users_by_keyword(keyword)
      deleted = users.delete(self.uid)
      # result = (deleted)? PostgresEngineSearches.update_keyword_users(users,keyword) : true
      result = (deleted)? update_pg_keyword_users(users,keyword) : true
    end
    result
  end


  def self.from_engine_searches(engine_searches_users)

    users = Array.new

    if engine_searches_users
      engine_search_users_arr = from_array_json_load(engine_searches_users)
      engine_search_users_arr.each do |user_engine_search|
        # us/er = User.new
        users << User.user_from_engine_search(user_engine_search)
      end
    end
    users

  end

  def self.user_from_engine_search (engine_search_users)
    user_engine = Hash.new
    engine_search_users.each do |id, name|
      # self.id = id.to_i
      # self.uid = id
      # self.name = name

      user_engine[id] = name
    end
    user_engine
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
  # def get_user_info
  #   PostgresUserInfos.get_info(self.id)
  # end

  def self.user_from_google_hash (google_hash)
    user = User.new
    user.id = google_hash["id"]
    user.name =  google_hash["name"]
    user.email = google_hash["email"]
    user.picture = google_hash["picture"]
    user.google_token = google_hash["google_token"]
    user.google_id = google_hash["id"]


    user
  end





  # def self.set_info_from_view(info,id)
  #   if info
  #     if info["title"]
  #       user = User.new
  #       user.id = id
  #       user.set_title(info["title"])
  #     end
  #
  #   end
  # end

  def self.get_mock_user
    user = User.new

    user.id = 280906882262216
    user.uid = '280906882262216'
    user.name = 'Tom Wongescu'
    user.email = 'danielsan@gmail.com'

    user
  end






  def global_weekly_unmatch_lactic
    # PostgresUser.global_weekly_unmatch_lactic
    global_pg_weekly_unmatch_lactic
  end

  private
  def confirmation_token
    if self.confirm_token.blank?
      self.confirm_token = SecureRandom.urlsafe_base64.to_s
    end
  end

end
