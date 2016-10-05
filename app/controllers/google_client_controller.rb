require 'rest-client'
# require 'google/api_client'
# require 'google/api_client'
require 'google/apis/calendar_v3'
require 'google/apis/plus_v1'
require 'google/apis/oauth2_v2'
require 'googleauth'
require 'googleauth/stores/file_token_store'

require 'fileutils'
class GoogleClientController < InstagramController




  OOB_URI = 'urn:ietf:wg:oauth:2.0:oob'
  APPLICATION_NAME = 'LACtic'
  CLIENT_SECRETS_PATH = 'client_secret.json'
  # CREDENTIALS_PATH = File.join(Dir.home, '.credentials',
  #                              "calendar-ruby-quickstart.yaml")
  SCOPE = Google::Apis::CalendarV3::AUTH_CALENDAR_READONLY




  def google_calendar_with_token(token)
    @GOOGLE_API_CLIENT = Signet::OAuth2::Client.new({client_id: '640455821666-2gfe5vdvah76nboe593cdpfmq8d77omk.apps.googleusercontent.com',
                                                          client_secret: 'BLTVmLyIF1X6pRFdEMl9Ox9v',
                                                          authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
                                                          token_credential_uri: 'https://accounts.google.com/o/oauth2/token',                                                          scope: "https://www.googleapis.com/auth/calendar",
                                                          # redirect_uri: "https://warm-citadel-1598.herokuapp.com/lactic_google_calendar_redirect"
                                                          # redirect_uri: lactic_google_calendar_redirect_url,
                                                          access_token: token
                                                         })


    @GOOGLE_API_CLIENT
  end
  helper_method :google_integrate
 def google_calendar_client_auth
   @GOOGLE_API_CLIENT = Signet::OAuth2::Client.new({client_id: '640455821666-2gfe5vdvah76nboe593cdpfmq8d77omk.apps.googleusercontent.com',
                                                         client_secret: 'BLTVmLyIF1X6pRFdEMl9Ox9v',
                                                         token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
                                                         authorization_uri: 'https://accounts.google.com/o/oauth2/auth',
                                                         scope: "https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/plus.login ",
                                                         # redirect_uri: "https://warm-citadel-1598.herokuapp.com/lactic_google_calendar_redirect"
                                                         redirect_uri: lactic_google_calendar_redirect_url
                                                        })


   @GOOGLE_API_CLIENT
 end

 # {
 # "access_token" : "ya29.AHES6ZTtm7SuokEB-RGtbBty9IIlNiP9-eNMMQKtXdMP3sfjL1Fc",
 #     "token_type" : "Bearer",
 #     "expires_in" : 3600,
 #     "refresh_token" : "1/HKSmLFXzqP0leUihZp2xUt3-5wkU7Gmu2Os_eBnzw74"
 # }
  def google_calendar_token_auth
    @GOOGLE_API_CLIENT  = Signet::OAuth2::Client.new({client_id: '640455821666-2gfe5vdvah76nboe593cdpfmq8d77omk.apps.googleusercontent.com',
                                                           client_secret: 'BLTVmLyIF1X6pRFdEMl9Ox9v',
                                                           token_credential_uri: 'https://accounts.google.com/o/oauth2/token',
                                                           # redirect_uri: url_for(:action => "https://warm-citadel-1598.herokuapp.com/lactic_google_calendar_redirect"),
                                                           redirect_uri: lactic_google_calendar_redirect_url,
                                                           code: params[:code]
                                                          })


    @GOOGLE_API_CLIENT
  end
 def update_from_google_response_token(response)


   session[:access_token] = response['access_token']
   session[:expires_in] = response['expires_in']
   session[:refresh_token] = response['refresh_token']
   # ::GOOGLE_CALENDAR_CLIENT.access_token =  session[:access_token]
   # puts "TOKEN UPDATED   #{response['access_token']}"
   session[:issued_at] = response['issued_at']
 end


 def update_google_user_from_sessoin
   # puts "UPDATING SESSION GOOGLE #{session[:access_token]}"
   if session[:access_token]
     cookies.permanent[:google_access_token]= session[:access_token]
     User.update_google_token(cookies[:osm_respond_id],session[:access_token])
   end
 end

 def reauth_google

   @GOOGLE_API_CLIENT = google_calendar_client_auth
   # puts "REDIRECT GOOGLE AITH  #{@GOOGLE_API_CLIENT.authorization_uri.to_s.inspect}"
   redirect_to @GOOGLE_API_CLIENT.authorization_uri.to_s

 end
 def fetch_token
   refreshed = 'false'
   response = @GOOGLE_API_CLIENT.fetch_access_token!
   begin
     update_from_google_response_token(response)

     if session[:refresh_token]
       refreshed = refresh_token
       # puts "REFRESHED ????? #{refreshed}"
       if session[:access_token] && !session[:access_token].empty?
         update_google_user_from_sessoin
       end

     end

     rescue
   end


   refreshed
 end

  def refresh_google_token

  end

 def refresh_token
   response = 'false'
   data = {
       :client_id => '640455821666-2gfe5vdvah76nboe593cdpfmq8d77omk.apps.googleusercontent.com',
       :client_secret => 'BLTVmLyIF1X6pRFdEMl9Ox9v',
       :refresh_token => session[:refresh_token],
       :grant_type => "refresh_token"
   }
   @response = ActiveSupport::JSON.decode(RestClient.post "https://accounts.google.com/o/oauth2/token", data)
   # puts "RESPONSE FROM GOOGLE REFRESH #{@response.inspect}"
   if @response["access_token"].present?

     session[:access_token] = @response['access_token']
     session[:expires_in] = @response['expires_in']
     response = true
     # puts "GOOGLE SESSION TOKEN REFRESHED #{ session[:access_token]}"
     # Save your token
   else
     # No Token
     # puts "GOOGLE SESSION TOKEN REFRESHED No Token!!!!!"
   end
 rescue RestClient::BadRequest => e
   # puts "BAD REQUEST FOR GOOGLE #{e.inspect}"
   # Bad request
 rescue
   # Something else bad happened
   # puts "BAD REQUEST FOR GOOGLE"
   response

 end




 ### redirect post from GOOGLE CALENDAR auth....
 #  error=access_denied
 def lactic_google_calendar_redirect
   # redirect_to profile_path

   # puts "IN LACTIC GOOGLE CAL  REDIRECT #{params.inspect}"

   if params[:error] && params[:error] == 'access_denied' || !params[:code]
     # redirect_to profile_path(:google_token => 'false')
     # redirect_to profile_path(:google_token => 'false')
     redirect_to  "#{session[:google_caller]}?google_token='false'"

   else

     # puts "IN LACTIC GOOGLE CAL  REDIRECT 2222 #{params.inspect}"
     @GOOGLE_API_CLIENT = google_calendar_token_auth

     response = fetch_token

     # redirect_to profile_path(:google_token => response, :google_access_token => session[:access_token])
     redirect_to  "#{session[:google_caller]}?google_token=#{response}&google_access_token=#{session[:access_token]}"
   end
 end



 def google_integrate

   if params[:google_token] && params[:caller]
     session[:google_caller] = params[:caller]
         if params[:google_token] == true
       # puts "  GOOGLE AUTH!"
     else
       # puts "ERROR FROM GOOGLE"
     end
   else
     # if cookies[:osm_respond_id] == '10153011850791938'
     #   puts "INIT GOOGLE...."
       google_init
     # end
   end
 end


  def google_init
    if  params[:caller]

      session[:google_caller] = params[:caller]
        reauth_google
      else
        respond_to do |format|
                # format.html {redirect_to profile_path }
                format.html {redirect_to :back, :params => params[:url_params] }
        end
      end
  end



  def lactic_to_google(lactic_session)

    event = ::GOOGLE_CALENDAR_CLIENT.create_event do |e|
      e.title = lactic_session.title
      e.start_time = lactic_session.start_date_time
      e.end_time = lactic_session.end_date_time
      e.description = lactic_session.description
      e.location = lactic_session.location
    end
    # puts "CALENDAR GOOGLE LACTIC EVENT SESSION CREATED  #{event.inspect}"
  end


  def send_event_test
    # event = ::GOOGLE_CALENDAR_CLIENT.create_event do |e|
    #   e.title = 'A LACTIC TEST Event'
    #   e.start_time = Time.now
    #   e.end_time = Time.now + (60 * 60) # seconds * min
    # end
    #
    # puts "EVENT FROM GOOGLE #{event.inspect}"
    #
    # event = ::GOOGLE_CALENDAR_CLIENT.find_or_create_event_by_id(event.id) do |e|
    #   e.title = 'An Updated Cool Event'
    #   e.end_time = Time.now + (60 * 60 * 2) # seconds * min * hours
    # end

    # puts "CALENDAR GOOGLE CALLED "


    @calendar_list = Google::CalendarList.new(
        :client_id =>'640455821666-2gfe5vdvah76nboe593cdpfmq8d77omk.apps.googleusercontent.com',
        :client_secret => 'BLTVmLyIF1X6pRFdEMl9Ox9v',
        :redirect_url => 'https://warm-citadel-1598.herokuapp.com/lactic_google_calendar_redirect',
        :refresh_token => session[:access_token]
    )



    list = @calendar_list.fetch_entries
    list.each do |calendar_list_entry|
      if calendar_list_entry.primary && calendar_list_entry.access_role == 'owner'
        # puts "PRIMARY GOOGLE CALENDAR EMAIL ADDRESS == #{calendar_list_entry.id}"
      end
    end


    # puts "CALENDAR LIST  #{list.inspect}"



  end


  def get_primary_gmail
    primary = ''
    @calendar_list = Google::CalendarList.new(
        :client_id =>'640455821666-2gfe5vdvah76nboe593cdpfmq8d77omk.apps.googleusercontent.com',
        :client_secret => 'BLTVmLyIF1X6pRFdEMl9Ox9v',
        :redirect_url => 'https://warm-citadel-1598.herokuapp.com/lactic_google_calendar_redirect',
        :refresh_token => session[:access_token]
    )



    list = @calendar_list.fetch_entries
    list.each do |calendar_list_entry|
      if calendar_list_entry.primary && calendar_list_entry.access_role == 'owner'
        # puts "PRIMARY GOOGLE CALENDAR EMAIL ADDRESS == #{calendar_list_entry.id}"
        primary = calendar_list_entry.id
      end
    end

    primary
  end




  # #<Google::Apis::PlusV1::Person:0x007f4423907608
  # @age_range=#<Google::Apis::PlusV1::Person::AgeRange:0x007f44238ef738 @min=21>,
  # @circled_by_count=53,
  # @cover=#<Google::Apis::PlusV1::Person::Cover:0x007f44238ecb78
  #        @cover_info=#<Google::Apis::PlusV1::Person::Cover::CoverInfo:0x007f44238e36b8
  #                      @left_image_offset=0,
  #                      @top_image_offset=0>,
  #        @cover_photo=#<Google::Apis::PlusV1::Person::Cover::CoverPhoto:0x007f44238e03c8
  #                      @height=940,
  #                      @url="https://lh3.googleusercontent.com/-jItxvfj509IpG7wjE9OYvxNBVEuU9Mk-qJIL_v_4dndDI6gOIgs15GOEVLOVLYvwAPvKghV=s630-fcrop64=1,0000373effffc731",
  #                      @width=940>,
  #        @layout="banner">,
  # @display_name="Sharona Nachum",
  # @etag="\"xw0en60W6-NurXn4VBU-CMjSPEw/gVrQfUWy88UWhHYoOX3_BKXacQU\"",
  # @gender="female",
  # @id="112950192124374741141",
  # @image=#<Google::Apis::PlusV1::Person::Image:0x007f44238cd660
  #                      @is_default=false,
  #                      @url="https://lh4.googleusercontent.com/-afWtvSOeapA/AAAAAAAAAAI/AAAAAAAABCA/vhFs5DyBwo0/photo.jpg?sz=50">,
  # @is_plus_user=true,
  # @kind="plus#person",
  # @language="en",
  # @name=#<Google::Apis::PlusV1::Person::Name:0x007f44238c41c8
  #          @family_name="Nachum",
  #          @given_name="Sharona">,
  # @object_type="person",
  # @places_lived=[#<Google::Apis::PlusV1::Person::PlacesLived:0x007f44238bcef0
  #                @primary=true,
  #                @value="Westwood, Los Angeles, CA">],
  #                @url="https://plus.google.com/+SharonaNachum",
  #                @verified=false>
  def google_plus
    primary_email = ''
    $authorization = Signet::OAuth2::Client.new(
        :authorization_uri => 'https://accounts.google.com/o/oauth2/auth',
        :token_credential_uri => 'https://accounts.google.com/o/oauth2/token',
        :client_id => '640455821666-2gfe5vdvah76nboe593cdpfmq8d77omk.apps.googleusercontent.com',
        :client_secret => 'BLTVmLyIF1X6pRFdEMl9Ox9v',
        :redirect_uri =>'https://warm-citadel-1598.herokuapp.com/lactic_google_calendar_redirect',
        :scope => "https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/plus.login ",
        :refresh_token => session[:access_token])
    plus = Google::Apis::PlusV1::PlusService.new
    plus.authorization = $authorization

    primary_email = get_primary_gmail

    person_plus = plus.get_person("me")


    google_plus_user = User.new
    google_plus_user.id = person_plus.id.to_i
    google_plus_user.name = "#{person_plus.name.given_name} #{person_plus.name.family_name}"

    image = (person_plus.image.url)?person_plus.image.url.gsub('sz=50','sz=150') : ''


    google_plus_user.picture = image
    google_plus_user.email = (primary_email)? primary_email : ''
    google_plus_user.google_token = session[:access_token]
    google_plus_user.matched = false
    google_plus_user.matched_user = ''
    google_plus_user.user_info = ''

    # puts "GOOGLE PLUS USER #{google_plus_user.inspect}"
    google_plus_user

  end
end