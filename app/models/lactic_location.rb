# require 'singleton'

class LacticLocation



  include PostgresUserInfos
  include PostgresLacticLocations

  include LacticLocationHelper

  attr_accessor :place_id, :id, :website, :icon, :name
  attr_accessor :latitude, :longitude, :origin, :url, :website
  # #<GooglePlaces::Spot:0x007f759f6304b8 @reference="CnRnAAAAT2Ifz_-3qdSTXeeRBzTr40uOwOB95BDnqVHY5iSY18ujBkVFIBy8L7RfBlgdeJI3MUWVPE9Z53AERbBcGi8Va2FHVlvnsXdICAN6vlZ24BRs0qTKWIHFFWG3yaPgR_C_1RDSqb7Qi5nikEHw1N1zvxIQaZo40RBQjGs5aXBkNEZ5bRoUlIgj7luGyP4SSno8ZCJy5RtVMQo",
#   @place_id="ChIJfayp1kNIHRURZ12k4dRwdtc",
#       @vicinity="La-Merkhav Street 22,
# Ramat Hasharon", @lat=32.1513141, @lng=34.83450759999999,
#       @viewport=nil,
#       @name="עדיטי יוגה",
#       @icon="https://maps.gstatic.com/mapfiles/place_api/icons/generic_business-71.png",
#       @types=["gym", "health", "point_of_interest", "establishment"],
#       @id="c12002f9ae75a91304431c3da9d9bf70c7239dfd",
#       @formatted_phone_number=nil,
#       @international_phone_number=nil,
#       @formatted_address=nil,
#       @address_components=nil,
#       @street_number=nil,
#       @street=nil,
#       @city=nil,
#       @region=nil,
#       @postal_code=nil,
#       @country=nil,
#       @rating=nil,
#       @price_level=nil,
#       @opening_hours=nil,
#       @url=nil, @cid=0,
#       @website=nil, @zagat_reviewed=nil,
#       @zagat_selected=nil, @aspects=[],
#       @review_summary=nil,
#       @photos=[], @reviews=[],
#       @nextpagetoken=nil, @events=[],
#       @utc_offset=nil>
  def self.location_from_google_place (google_place)
    # https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJ7eh0UI9HHRUREUjfb9nLwco&key=AIzaSyBPY8MIKf-2zkLiA78udRlsKNSOePzJloQ
    location = Hash.new
    location["url"] ="https://maps.googleapis.com/maps/api/place/details/json?placeid=#{google_place.id}&key=AIzaSyBPY8MIKf-2zkLiA78udRlsKNSOePzJloQ"
    location["name"] = PostgresHelper.escape_for_postgres(google_place.name)
    location["id"] = google_place.place_id
    location["website"] = google_place.website || location["url"]
    location["icon"] = google_place.icon
    location["street"] = PostgresHelper.escape_for_postgres(google_place.street)
    location["city"] = PostgresHelper.escape_for_postgres(google_place.city)
    location["zip"] = google_place.postal_code
    location["location_origin"] = "google"
    location
  end

  # {"category"=>"Local business",
  # "category_list"=>
  # [{"id"=>"184405378265823",
  # "name"=>"Gym"}],
  # "location"=>{"street"=>"",
  # "city"=>"", "zip"=>"",
  # "latitude"=>32.4098554362,
  # "longitude"=>35.0435405773},
  # "name"=>"Sport Time",
  # "id"=>"112835418840767"}
  def self.location_from_facebook (facebook_location)
    location = Hash.new
    location["name"] = PostgresHelper.escape_for_postgres(facebook_location["name"])
    location["id"] = facebook_location["id"]
    location["website"] = "https://www.facebook.com/#{facebook_location["id"]}"
    # location["icon"] = facebook_location.icon
    # puts "FACEBOOK LOCATION ADDRESS #{facebook_location["location"].inspect}"
    # puts "FACEBOOK LOCATION ADDRESS 2#{facebook_location[:location].inspect}"
    location["street"] = PostgresHelper.escape_for_postgres(facebook_location["location"]["street"])
    location["city"] = PostgresHelper.escape_for_postgres(facebook_location["location"]["city"])
    location["zip"] = facebook_location["location"]["zip"]
    location["state"] = PostgresHelper.escape_for_postgres(facebook_location["location"]["state"])
    location["country"] = PostgresHelper.escape_for_postgres(facebook_location["location"]["country"])
    location["location_origin"] = "facebook"
    location
  end



  def from_postgres(user_info_record)
    user_info = UserInfo.new
    user_info.from_postgres(user_info_record)
    user_info
  end



  def location_from_postgres(location_row)


  end
  ## Default distance 10 km
  def nearby_users(distance_in_km=10)
    result = Hash.new
    # distance_in_km = distance_in_km || 10
    if (self.longitude && self.latitude )
      # sw_ne_points = LacticLocationHelper.bounding_box([self.latitude,self.longitude],distance_in_km)
      sw_ne_points = bounding_box([self.latitude,self.longitude],distance_in_km)
      # result = PostgresUserInfos.locations_nearby(sw_ne_points)
      result = pg_locations_nearby(sw_ne_points)
    end
    result

  end


  def set_new_locations

  end
  def nearby_locations(distance_in_km=10)
    result = Array.new
    # distance_in_km = distance_in_km || 10
    if (self.longitude && self.latitude )
      # sw_ne_points = LacticLocationHelper.bounding_box([self.latitude,self.longitude],distance_in_km)
      sw_ne_points = bounding_box([self.latitude,self.longitude],distance_in_km)
      # result = PostgresUserInfos.locations_nearby(sw_ne_points)
      result = pg_locations_nearby(sw_ne_points)
    end
    result

  end

  def self.valid_coordinates(lat,longt)
    lat && longt && lat.to_i && lat.to_i != 0 && longt.to_i && longt.to_i != 0
  end

  def location_url


    if self.id && self.origin
    case self.origin
      when 'facebook'
        self.website= "http://facebook.com/#{self.id}"
        self.url = ''
      when 'google'
        url = "https://maps.googleapis.com/maps/api/place/details/json?placeid=#{self.id}&key=AIzaSyBPY8MIKf-2zkLiA78udRlsKNSOePzJloQ"
        response = RestClient.get url, {:accept => :json}
        self.url = ''
        self.website = ''
        if response
          json_response_url  = response.to_s.split('"url" :')[1]
          json_response_url = (json_response_url)? json_response_url.split(',')[0].gsub('"','') :''

          json_website_url =  response.to_s.split('"website" :')[1]
          # puts "REPONSE WEBSITE #{json_website_url}"
          json_website_url = (json_website_url) ? json_website_url.split(',')[0].gsub('"','') :''
          self.url = json_response_url
          self.website = json_website_url

        end
    end
    else
      self.url = ''
      self.website = ''
    end

  end




end