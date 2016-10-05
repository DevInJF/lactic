class LacticLocationsController < NotificationsController



  # before_action :set_location_params
  # Releveant GOOGLE TYPES :
  # bicycle_store, gym, stadium, spa, rv_park
  # @nearest_locations ||= Array.new

  def get_nearest(lat,longt)
    # puts "GET NEAREST FROM SET LOCATIONS"

    Thread.new {
    if !cookies[:lactic_mock_respond_id] || cookies[:lactic_mock_respond_id].empty?


          # mock ={"category"=>"Local business",
          # "category_list"=>
          # [{"id"=>"184405378265823",
          # "name"=>"Gym"}],
          # "location"=>{"street"=>"",
          # "city"=>"", "zip"=>"",
          # "latitude"=>32.4098554362,
          # "longitude"=>35.0435405773},
          # "name"=>"Sport Time",
          # "id"=>"112835418840767"}
          # locations << LacticLocation.location_from_facebook(mock)
          # facebook_locations = FacebooksController.locations(cookies[:osm_respond_id],cookies[:lactic_latitude],cookies[:lactic_longitude])



          nearest_locations = (lat && longt)? facebook_lactic_locations(lat,longt) : Array.new
          locations = (lat && longt)? google_lactic_locations(lat,longt) : Array.new
          locations.each do |location|
            nearest_locations << location
          end

          # @nearest_locations = @nearest_locations

      # last_lactic_locations(nearest_locations)


          # global = LacticGlobal.instance
          # global.last_lactic_locations = nearest_locations



          lactic_location =  LacticLocation.new
          lactic_location.latitude = lat
          lactic_location.longitude = longt
          lactic_location.new_pg_location( lactic_location.latitude,lactic_location.longitude,nearest_locations)
          # lactic_location.update_pg_location( lactic_location.latitude,lactic_location.longitude,nearest_locations)

         # nearest_locations
      # puts "NEAREST LENGTH #{$nearest_locations.length}"
        # end
        # @nearest_locations = locations
        # locations
        # end
        # GOOGLE_LOCATIONS_CLIENT.predictions_by_input(
        #     'San F',
        #     lat: 0.0,
        #     lng: 0.0,
        #     radius: 20000000,
        #     types: 'geocode',
        #     language: I18n.locale,
        # )

    end
    }
    # end

  end



  def nearby_locations(lat,long,distance_in_km=10)
    lactic_location = LacticLocation.new
    lactic_location.latitude = lat
    lactic_location.longitude = long

    nearest_locations = Array.new
    nearest_locations = lactic_location.nearby_locations(distance_in_km)

    if !nearest_locations || nearest_locations.length == 0 && LacticLocation.valid_coordinates(lat,long)

      get_nearest(lat,long)
      # nearest_locations = lactic_location.nearby_locations(distance_in_km)

    end

    nearest_locations
  end


    # lactic_location.nearby_users(distance_in_km)



  def nearby_users(lat,long,distance_in_km=10)
    lactic_location = LacticLocation.new
    lactic_location.latitude = lat
    lactic_location.longitude = long

    lactic_location.nearby_users(distance_in_km)


    # lactic_location.nearby_users(distance_in_km)

  end


  # private



  def facebook_lactic_locations(lat,longt)
    locations = Array.new
    facebook_locations = FacebooksController.locations(cookies[:lactic_fb_id],lat,longt)

    facebook_locations.each do|facebook_location|
      locations << LacticLocation.location_from_facebook(facebook_location)
    end

    (locations)? locations : Array.new
  end

  def google_lactic_locations(lat,longt)
    locations = Array.new
    # if (cookies["lactic_latitude"] && cookies["lactic_longitude"])
    # if (cookies["lactic_latitude"] && cookies["lactic_longinearest_locationstude"])
      # Thread.new{
      google_places = GOOGLE_LOCATIONS_CLIENT.spots(lat,longt, :types => ['bicycle_store', 'gym', 'stadium', 'spa', 'rv_park'], :radius => 10000)
      google_places.each do |google_place|
        locations << LacticLocation.location_from_google_place(google_place)
      end

    # end
    locations

  end

  # def share_location
  #
  #   puts "SHARE LOCATION ??? #{params.inspect}"
  #   session[:location_shared] = params[:location_shared]
  #   puts "SHARE LOCATION ??? #{session[:location_shared].inspect}"
  #   respond_to do |format|
  #     # format.html {redirect_to profile_path }
  #     format.html {redirect_to :back, :params => params[:url_params] }
  #   end
  # end
end