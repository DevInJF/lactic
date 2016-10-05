class FacebooksController < ApplicationController
  helper_method :facebook_friends


  #GET graph.facebook.com
  #   /search?
  # q=coffee&
  # type=place&
  # center=37.76,-122.427&
  # distance=1000
def self.osm_locations(currentUser,lat,longt)
  if (currentUser)
    # @facebook = Facebook.get_facebook(currentUser.uid)
    # facebookm = Facebook.new
    # facebookm.uid = currentUser.uid

    @facebook = get_facebook_model(uid)
    # Rails.application.config.FACEBOOK_LOCATIONS =
    @facebook.facebook_osm_locations(currentUser,lat,longt)


  end

end



  def self.locations(user_uid,lat,longt)
    if (user_uid)

      # facebookm = Facebook.new
      # facebookm.uid = user_uid
      # @facebook = Facebook.get_facebook(user_uid)
      @facebook = get_facebook_model(user_uid)

      # Rails.application.config.FACEBOOK_LOCATIONS =
      @facebook.facebook_locations(user_uid,lat,longt)

    else
      Array.new
    end
  end


  def self.facebook_invite(user,to)
    if user.uid && to.uid
      Facebook.send_invite(user,to)
    end
  end
  def self.set_facebook_contacts(uid)

    if uid
      # facebookm = Facebook.new
      # facebookm.uid = uid
      # @facebook = Facebook.get_facebook(uid)
      @facebook = get_facebook_model(uid)
      @facebook.facebook_friends
    end
  end


  def self.set_fb_lactic_contacts(uid)
    if uid
    # facebookm = Facebook.new
    # puts "SET LACTIC USERS "
    # facebookm.uid = uid
    # @facebook = Facebook.get_facebook(uid)
    #   set_facebook_model(uid)

    @facebook = get_facebook_model(uid)
    @facebook.fb_lactic_contacts

    end
  end



  def self.app_invite(uid,url)
    if uid
    # facebookm = Facebook.new
    # facebookm.uid = uid


    # @facebook = Facebook.get_facebook(uid)
    @facebook = get_facebook_model(uid)
    @facebook.fb_app_invite(url)

    end
  end

  def self.new_facebook_user(user)
    facebook_model = Facebook.new
    facebook_model.uid = user.uid
    facebook_model.access_token = user.access_token
    facebook_model.access_token = user.access_token_expiration_date

    begin
    facebook_model.new_facebook

    rescue

      puts "RESCUE FROM FACEBOOK "
    end



  end

  def self.authanticate(user_auth,oauth)
    # puts "AUTH FCAEBOOK USER auth #{user_auth.inspect}"

    facebook_auth = Facebook.set_facebook_from_user(user_auth)

    # puts "OAUTH ???? #{oauth}"


    facebook_auth.authanticate_facebook oauth
  end



  def self.update_facebook(current_user)
    if (current_user.uid)
      facebookm = Facebook.new
      facebookm.uid = current_user.uid
      facebookm.access_token = current_user.access_token
      facebookm.access_token_expiration_date = current_user.access_token_expiration_date

      facebookm.update_facebook_user
    end

  end


  def self.update_facebook_from_model(facebook_model)
    if facebook_model && facebook_model.uid
      facebook_model.update_facebook_user
    end
  end


  def self.get_facebook_model(uid)
    @facebook_model = Facebook.new
    @facebook_model.uid = uid
    @facebook_model.get_facebook
  end


end
