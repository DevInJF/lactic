require "instagram"
class InstagramController < ApplicationController

  # CODE_REDIRECT_URI = instagram_code_callback_path

  # TOKEN_REDIRECT_URI = ""
  # INSTAGRAM_AUTH_URL = "https://api.instagram.com/oauth/authorize/?client_id=8cee0bcde6f54cb793d37cb4f0c303ee&redirect_uri=#{CODE_REDIRECT_URI}&response_type=code"
  $INSTAGRAM_TOKEN_URL = "https://api.instagram.com/oauth/authorize/?client_id=8cee0bcde6f54cb793d37cb4f0c303ee&redirect_uri=https://warm-citadel-1598.herokuapp.com/instagram_token_callback&response_type=token"
  $INSTAGRAM_CODE_URL = "https://api.instagram.com/oauth/authorize/?client_id=8cee0bcde6f54cb793d37cb4f0c303ee&redirect_uri=https://warm-citadel-1598.herokuapp.com/instagram_code_callback&response_type=code&scope=public_content"


  #   # redirect_to "https://api.instagram.com/oauth/authorize/?client_id=8cee0bcde6f54cb793d37cb4f0c303ee&redirect_uri=https://warm-citadel-1598.herokuapp.com/instagram_token_callback&response_type=token"




  def code_callback

    response = Instagram.get_access_token(params[:code], :redirect_uri => instagram_code_callback_url)
    session[:instagram_access_token] = response.access_token
    # puts "INTAGRAM CLIENT response ACCESS TOKEN #{session[:instagram_access_token].inspect}"
    respond_to do |format|
      # format.html {redirect_to profile_path }
      format.html {redirect_to :back, :params => params[:url_params] }
    end
  end


  ## callback from Instagram auth
  def token_callback
    # puts "INTAGRAM CLIENT response ACCESS TOKEN ???? #{params.inspect}"
    if params[:access_token]
      session[:instagram_access_token] = params[:access_token]
      # puts "INTAGRAM SESSION TOKEN #{params[:access_token].inspect}"

    end
    respond_to do |format|
      format.html {redirect_to profile_path }
      # redirect_to :back, :params => params[:url_params]
    end
  end



  def instagram_lactic_pic
    client = Instagram.client(:access_token => session[:instagram_access_token])
    user = client.user
    # puts "INSTAGRAM USER #{user.username} IMAGE #{user.profile_picture}"

    lactic_images = Array.new
    begin
      lactic_tags = client.tag_recent_media('LACtic')
      lactic_tags.each do |media_item|
        lactic_images << media_item.images.thumbnail.url
      end
    rescue
      puts "RESCUE FROM INSTAGRAM !"
    end
    {:lactic_instagram_images => lactic_images  }
  end



  def instagram_user

    client = Instagram.client(:access_token => session[:instagram_access_token])

    user = client.user
    # puts "INSTAGRAM USER #{user.username} IMAGE #{user.profile_picture}"

    response = client.user_recent_media
    album = [].concat(response)
    instagram_album = Array.new
    lactic_images = Array.new



    begin

    max_id = response.pagination.next_max_id

    lactic_tags = client.tag_recent_media('LACtic')



    lactic_tags.each do |media_item|
      lactic_images << media_item.images.thumbnail.url
    end

    instagram_album = Array.new
    album.each do |media_item|
      instagram_album << media_item.images.thumbnail.url
    end
    rescue
      puts "RESCUE FROM INSTAGRAM !"
    end



    user.profile_picture
    {:album => instagram_album, :picture => user.profile_picture, :lactic_instagram_images => lactic_images, :url => "https://www.instagram.com/#{user.username}/"  }
  end


  def user_proporties
    client = Instagram.client(:access_token => session[:instagram_access_token])
    user = client.user

    {:picture => user.profile_picture, :url => "https://www.instagram.com/#{user.username}/"}



  end


  def user_search
    client = Instagram.client(:access_token => session[:instagram_access_token])
    html = "<h1>Search for users on instagram, by name or usernames</h1>"
    for user in client.user_search("instagram")
      html << "<li> <img src='#{user.profile_picture}'> #{user.username} #{user.full_name}</li>"
    end
    html
  end





end
