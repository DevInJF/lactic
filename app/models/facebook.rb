require 'monitor.rb'


class Facebook < ActiveRecord::Base




  attr_accessor :facebook_friends_uids
  attr_accessor :facebook_osm_friends_uids
  attr_accessor :facebook_osm_locations
  attr_accessor :set_new_auth_properties
  attr_accessor :remove_user

  include PostgresFacebook

  def facebook_friends
    # @mutex = Mutex.new
    # @mutex.synchronize do
    # if(uid)
      begin
        # facebook_model1 = Facebook.new
        # facebook_model1.uid = uid
            @facebook_model = self.get_facebook
            facebook = Facebook.get_facebook_object(@facebook_model)
            fb_friends = facebook.get_object("/#{uid}/taggable_friends")

            facebook_friends = {}
            taggable_friends = fb_friends



          facebook_friends_uids = Array.new

          fb_friends.each { |friend| facebook_friends_uids <<  {:name => friend["name"].gsub("'", ''),:id => friend["id"], :picture => friend["picture"]["data"]["url"]} }

          facebook_friends = Hash[facebook_friends_uids.map{|h| [h[:picture], h]}].values

          fb_friends = fb_friends.next_page

          while fb_friends do
            # puts "IN LOOP"

            facebook_friends_uids2 = Array.new
            fb_friends.each { |friend| facebook_friends_uids2 << {:name => friend["name"].gsub("'", ''),:id => friend["id"], :picture => friend["picture"]["data"]["url"]} }

            # puts "uid2 #{facebook_friends_uids2.length}"

            facebook_friends_uids2.each {|friend| facebook_friends_uids << friend}
            fb_friends = fb_friends.next_page

            if fb_friends

              # puts "FB NEX=T...."
            end
            # puts "TAGGABLE FRIENDS #{Hash[facebook_friends.map{|h| [h[:picture], h]}]}"

            h1 = Hash[facebook_friends.map{|h| [h[:picture], h]}]

            # puts "ROUND H1 SAVE CONTATCS....#{h1.length}"

            h2 = Hash[facebook_friends_uids.map{|h| [h[:picture], h]}]

            # puts "ROUND H2 SAVE CONTATCS....#{h2.length}"

            facebook_friends = h1.merge(h2).values


            # puts "ROUND 1 SAVE CONTATCS....#{facebook_friends.length}"
          end


          # puts "SAVE CONTATCS...."

          save_contacts_retrieve(uid,facebook_friends, false)
          save_hashed_db_contacts(uid,facebook_friends)
          # }
          # end

      rescue Exception => e
        puts "EXCEPTION FROM FACEBOK FRIENDS #{e.message}"
      end
    # end
  end


  def fb_app_invite(redirect_url)
    begin
      # facebook_model1 = Facebook.new
      # facebook_model1.uid = uid


    facebook_model = self.get_facebook
    facebook = Facebook.get_facebook_object(facebook_model)

    RestClient.get 'http://www.facebook.com/dialog/send', :params => {:app_id => 1464889360497123, :link => 'https://warm-citadel-1598.herokuapp.com/', :redirect_uri => redirect_url, :access_token => facebook.access_token  }

    # dialog =  "FACEBOOK DIALOG  #{r.inspect}"
    #   facebook.put_connections("me", 'http://www.facebook.com/dialog/send', {:app_id => '1464889360497123', :link => 'https://warm-citadel-1598.herokuapp.com/', :redirect_uri => redirect_url  })

    # fb_invite = facebook.get_object("http://www.facebook.com/dialog/send?
    # app_id=1464889360497123
    # &amp;link=https://warm-citadel-1598.herokuapp.com/
    # &amp;redirect_uri=#{redirect_url}")

    rescue Exception => e
      puts "FACEBOOK DIALOG ERROR #{e.message}"
    end

  end


  ### A call to FB Graph API in request fot the user OSM FB friends
  def fb_lactic_contacts
    # puts "facebook_osm_friends"
    # @mutex_2 = Mutex.new
    # @mutex_2.synchronize do
    self.facebook_osm_friends_uids = []

    if(uid)

      # facebook_model1 = Facebook.new
      # facebook_model1.uid = uid
      facebook_model = self.get_facebook
      facebook = Facebook.get_facebook_object(facebook_model)

      # Fetching all user's FB friends that are on the LActic platform also...

      fb_friends = facebook.get_object("/#{uid}/friends")

      # puts "FB FRIENDS #{fb_friends.inspect}"
      fb_friends.each { |friend| facebook_osm_friends_uids << {:name => friend["name"].gsub("'", ''),:id => friend["id"], :picture => "https://graph.facebook.com/#{friend["id"]}/picture?type=large"} }

      #Thread .new {
        lactic_contacts = {}
        while fb_friends.next_page do
          facebook_osm_friends_uids2 = []
          fb_friends.each { |friend| facebook_osm_friends_uids2 << {:name => friend["name"].gsub("'", ''),:id => friend["id"], :picture => "https://graph.facebook.com/#{friend["id"]}/picture?type=large"} }

          facebook_osm_friends_uids2.each {|friend| facebook_osm_friends_uids << friend}
          fb_friends = fb_friends.next_page

          h1 = Hash[lactic_contacts.map{|h| [h[:picture], h]}]
          h2 = Hash[self.facebook_osm_friends_uids.map{|h| [h[:picture], h]}]
          lactic_contacts= h1.merge(h2).values

        end

        save_contacts_retrieve(uid,lactic_contacts, true)

      # }
    # end
    end
  end


  def save_hashed_db_contacts(uid,contacts)
    facebook_friends_json = ''



    if contacts && !(contacts.empty?)
      contacts.each do |friend|
        facebook_friends_json.concat("{'#{friend[:name]}' : {'name' : '#{friend[:name].gsub("'", '')}','id' : '#{friend[:id]}', 'picture' : '#{friend[:picture].gsub("\\\\\\\\u0026", '&').gsub("\\\\u0026", '&')}'}},".gsub("'", '"'))

      end
      facebook_friends_json = '[' + facebook_friends_json + ']'
      facebook_friends_json = facebook_friends_json.gsub(',]', ']')

    end

    # puts "SAVE HASHED FB CONATCTS #{facebook_friends_json.inspect}"

    UsersController.save_hashed_fb_contacts(uid,facebook_friends_json)

  end

  def save_contacts_retrieve(uid,contacts, lactic_contacts)

    # puts "SAVE CONTACTS 11111"

    facebook_friends_json = ''

    facebook_friends_uids = []

    if contacts && !(contacts.empty?)
      contacts.each do |friend|
        facebook_friends_json.concat("{'name' : '#{friend[:name].gsub("'", '')}','id' : '#{friend[:id]}', 'picture' : '#{friend[:picture].gsub("\\\\\\\\u0026", '&').gsub("\\\\u0026", '&')}'},".gsub("'", '"'))
        facebook_friends_uids << friend[:id]
      end
      facebook_friends_json = '[' + facebook_friends_json + ']'
      facebook_friends_json = facebook_friends_json.gsub(',]', ']')

    end

    # puts "SAVE CONTACTS 22222"

    UsersController.save_contacts_retrieve(uid,facebook_friends_json,lactic_contacts,facebook_friends_uids)

  end


  def facebook_locations(user_uid,lat,longt)
    facebook_locations_arr = Array.new
    facebook_locations = Array.new

    if (user_uid && lat && longt)


      # facebook_model = Facebook.new
      # facebook_model.uid = user_uid
      @facebook_model = self.get_facebook
      @facebook = Facebook.get_facebook_object(@facebook_model)
      # fb_locations = @facebook.get_object("/search?q=sport&type=place&center=#{lat},#{longt}&distance=10000")
      fb_locations = @facebook.get_object("/search?type=place&center=#{lat},#{longt}&distance=10000")


      fb_locations.each do |location|
        # facebook_locations_arr  << {:name => location["name"].gsub("'", ''),:id => location["id"]}
        facebook_locations  << location
        # puts "FACEBOOK LOATION #{location.inspect}"
      end

        while fb_locations.next_page do
          # facebook_locations_arr2 = Array.new
          # fb_locations.each { |location| facebook_locations_arr << {:name => location["name"].gsub("'", ''),:id => location["id"]} }
          fb_locations.each { |location| facebook_locations << location }

          # facebook_locations_arr.each {|location| facebook_locations << location}
          fb_locations = fb_locations.next_page



        end

    end
    facebook_locations
    # end
  end

  # def fetching_update()
  #   # puts "#{self.facebook_friends_uids}"
  #   Rails.application.config.FACEBOOK_FRIENDS.to_json
  # end

  # def self.remove_user(uid, from)
  #
  #   if from == '10153011850791938'
  #     puts "REQUEST FROM SHARON TO REMOVE #{uid}"
  #     # @facebook_model = Facebook.get_facebook(from)
  #     # facebook = Facebook.get_facebook_object(@facebook_model)
  #     result = Koala::Facebook::GraphAPIMethods.delete_object(uid)
  #     # result = facebook.delete_object(uid)
  #     puts "REQUEST FROM SHARON TO REMOVE #{result.inspect}"
  #   end
  #
  # end


  def get_facebook
    # facebook = Facebook.new
    # facebook.uid = uid
    # PostgresFacebook.get_facebook(facebook)
   get_pg_facebook(self)

  end

  def self.get_facebook_object(facebook)
    # @mutex.synchronize do
    if (facebook)
      # puts "GET FACEBOOK OBJECT"
      Koala::Facebook::API.new(facebook.access_token)


    end
    # end
  end


  def self.send_invite(from,to)
    facebook_model = Facebook.new
    facebook_model.uid = from.uid
    @facebook_model = facebook_model.get_facebook
    facebook_object = Facebook.get_facebook_object(@facebook_model)
    # facebook_object = get_facebook_object(self)
    facebook_object.put_object(to.uid, "apprequests", {:message => "#{from.name} invites you to LActic"})
  end

  def self.set_facebook_from_user(user)

    facebook = Facebook.new
    facebook.access_token_expiration_date= user.access_token_expiration_date
    facebook.access_token= user.access_token
    facebook.uid= user.uid
    facebook
  end

  def self.authanticate(facebook)
    facebook.authanticate_facebook
  end

  def new_facebook
    faceboook_user = Facebook.new

    faceboook_user.uid = self.uid
    faceboook_user.access_token = self.access_token
    faceboook_user.access_token_expiration_date = self.access_token_expiration_date

    if facebook && facebook.access_token_expiration_date - 60.days > Date.today

      puts "UPDATE FACEBOOK...."

      # puts "UPDATING FACEBOOK USER "
      # facebook = set_new_auth_properties(facebook,oauth)
      refresh_facebook_token
      # result = PostgresFacebook.update_facebook(self)
      result = update_pg_facebook(self)

    else
      puts "NEW  FACEBOOK...."


      # if self.access_token && self.access_token_expiration_date && self.access_token_expiration_date- 60.days > Date.today
      #   puts "UPDATING NEW !!!!!! FACEBOOK USER WITH OAUTH"
      #   faceboook_user.access_token=  self.access_token
      #   faceboook_user.access_token_expiration_date =  self.access_token_expiration_date
      #
      # else
      #   puts "UPDATING NEW !!!!!! FACEBOOK USER WITH OAUTH"
      # faceboook_user = set_new_auth_properties(faceboook_user,oauth)
      refresh_facebook_token
      # end
      # result = PostgresFacebook.new_facebook(self)
      result = new_pg_facebook(self)

    end
  end

  def authanticate_facebook oauth

    facebook_model = Facebook.new
    facebook_model.uid = self.uid
    facebook = facebook_model.get_facebook

    # puts "FB USER SELF #{self.inspect}"

    if facebook && facebook.access_token && facebook.access_token_expiration_date && facebook.access_token_expiration_date - 60.days > Date.today
     # puts "FACEBOOK INSPECT #{facebook.inspect}"
     # puts "FACEBOOK date today  #{Date.today}"
     result =facebook
      # PostgresFacebook.update_facebook(facebook)
    else
      faceboook_user = Facebook.new

      faceboook_user.uid = self.uid
      faceboook_user.access_token = self.access_token
      faceboook_user.access_token_expiration_date = self.access_token_expiration_date

      if facebook && facebook.access_token_expiration_date - 60.days > Date.today


        # puts "UPDATING FACEBOOK USER "
        # facebook = set_new_auth_properties(facebook,oauth)
        refresh_facebook_token
        # result = PostgresFacebook.update_facebook(self)
        result = update_pg_facebook(self)

      else
        # if self.access_token && self.access_token_expiration_date && self.access_token_expiration_date- 60.days > Date.today
        #   puts "UPDATING NEW !!!!!! FACEBOOK USER WITH OAUTH"
        #   faceboook_user.access_token=  self.access_token
        #   faceboook_user.access_token_expiration_date =  self.access_token_expiration_date
        #
        # else
        #   puts "UPDATING NEW !!!!!! FACEBOOK USER WITH OAUTH"
          # faceboook_user = set_new_auth_properties(faceboook_user,oauth)
          refresh_facebook_token
        # end
        # result = PostgresFacebook.new_facebook(self)
        result = new_pg_facebook(self)

      end
    end
    result

  end



  def update_facebook_user


    # facebook = Facebook.new
    # facebook.uid = current_user.uid
    # facebook.access_token = current_user.access_token
    # facebook.access_token_expiration_date = current_user.access_token_expiration_date

    # PostgresFacebook.update_facebook(facebook)
    update_pg_facebook(self)

  end





  def set_new_auth_properties(facebook,oauth)


    # puts "SET NEW AUTH PRORP FOR #{facebook.inspect}"
    # puts "SET NEW inspect AUTH   #{oauth.inspect}"
    begin
      # auth = Koala::Facebook::OAuth.new(ENV["FACEBOOK_KEY"], ENV["FACEBOOK_SECRET"])
      # oauth = facebook_oauth_retrieve
      # puts "SET FACEBOOK OAUTH #{oauth.inspect}"
      # new_access_info = oauth.exchange_access_token_info facebook.access_token
      new_access_token = Koala::Facebook::OAuth.exchange_access_token facebook.access_token
      # new_access_token = new_access_info["access_token"]

      # puts "NEW ACCESS #{new_access_token.inspect}"
      # puts "NEW ACCESS token #{new_access_info["access_token"].inspect}"
      # puts "NEW ACCESS EXPIERS #{new_access_info["expires"]}"
      # puts "NEW ACCESS EXPIERS #{new_access_info["expires"].to_i.seconds}"


      # new_access_expires_at = DateTime.now + new_access_info["expires"].to_i.seconds
      new_access_expires_at = DateTime.now + 60.days

      facebook.access_token=  new_access_token
      facebook.access_token_expiration_date =  new_access_expires_at


      # puts "SETeddddd NEW AUTH PRORP FOR #{facebook.inspect}"
    rescue Koala::Facebook::APIError => e
      logger.info e.to_s

      facebook = nil
    end
    facebook
  end




  def refresh_facebook_token
    # Checks the saved expiry time against the current time
    # if facebook_token_expired?
    # puts "REFRESGHING FB TOKEN"
    begin
      # current_access_token ||= self.access_token
      # self.access_token = current_access_token
      # puts "EXPIRE DATE ON REFRESH current TOKEN #{self.access_token}"
      # Get the new token
      new_token = facebook_oauth.exchange_access_token_info(self.access_token)
      # puts "EXPIRE DATE ON REFRESH NEW TOKEN #{new_token}"

      # Save the new token and its expiry over the old one
      self.access_token = new_token['access_token']
      self.access_token_expiration_date = DateTime.now + (new_token['expires'].to_i).seconds
      # save

        # puts "EXPIRE DATE ON REFRESH #{self.access_token_expiration_date}"
    rescue Koala::Facebook::APIError => e
    logger.info e.to_s
    # puts "EXPIRE DATE ON REFRESH ERROR #{e.to_s}"
     facebook = nil

    end
    # end
  end

  # Connect to Facebook via Koala's oauth
  def facebook_oauth
    # Insert your own Facebook client ID and secret here
    # auth = Koala::Facebook::OAuth.new(ENV["FACEBOOK_KEY"], ENV["FACEBOOK_SECRET"])

  @facebook_oauth = Koala::Facebook::OAuth.new(ENV["FACEBOOK_KEY"], ENV["FACEBOOK_SECRET"])



  end



end
