module PostgresLacticLocations

  include LacticLocationHelper
  include PostgresHelper




  def new_pg_location(lat,long,location)
    lactic_location = Array.new
    query = "INSERT INTO lactic_locations (latitude,longitude,location,created_at,updated_at) VALUES (#{lat},#{long},'#{location.to_json}',NOW(),NOW()) RETURNING *"
    # puts "INSERT INTO lactic_locations (latitude,longitude,location,created_at,updated_at) VALUES (#{lat},#{long},'#{location.length}',NOW(),NOW()) RETURNING *"
    result2 = postgres_exec(query)
    result2.each do|res|
      # puts "RESULT ROW #{row.inspect}"
      lactic_location = PostgresHelper.json_load(res["location"])

    end
    lactic_location
  end


  def update_pg_location(lat,long,location)
    lactic_location = Array.new
    query = "UPDATE lactic_locations SET location ='#{location.to_json}' ,updated_at = NOW() WHERE latitude = #{lat} AND longitude = #{long} RETURNING *"
    # puts "INSERT INTO lactic_locations (,location,created_at,updated_at) VALUES (#{lat},#{long},'#{location.length}',NOW(),NOW()) RETURNING *"
    result2 = postgres_exec(query)
    result2.each do|res|
      # puts "RESULT ROW #{row.inspect}"
      lactic_location = PostgresHelper.json_load(res["location"])
    end
    lactic_location
  end



  def pg_locations_nearby(sw_ne_points)

    sql = "SELECT * FROM lactic_locations WHERE "
    condition_sql = within_bounding_box(sw_ne_points[0],sw_ne_points[1],sw_ne_points[2],sw_ne_points[3],'latitude','longitude')

    lactic_locations = Array.new

    result2 = postgres_exec(sql+condition_sql+' LIMIT 3')
    result2.each do |row|
      lactic_location = Array.new
      lactic_location = PostgresHelper.json_load(row["location"])
      lactic_location.each do |location|
        lactic_locations << location
      end

    end

    lactic_locations
  end



end