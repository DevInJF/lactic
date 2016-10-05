
module PostgresUserInfos

  include LacticLocationHelper
  include PostgresHelper

  def get_pg_oid(picture_file)
    lo = (picture_file)? USERS_POSTGRES_CONNECTION.lo_import(picture_file) : nil
    (lo)? lo.oid : nil

  end

  def save_pg_new_info(user_info)
    result = nil
    # oid = (user_info.picture)? user_info.picture.identifier.to_i : -1
    #
    # about = (user_info.about && !user_info.about.empty?)? user_info.about.map {|str| "\"#{str}\""}.join(',') : ''
    # about = '{'+about+'}'
    # location = user_info.location && !user_info.location.empty? ? user_info.location.to_json : nil




    user_info_record = get_pg_user_info(user_info.id)



    if user_info_record
      result = true
    else
      query = set_insert_query(user_info)
      # result_response = (location)?postgres_exec("INSERT INTO user_infos (id, title,about,name ,location, location_id,picture,public_service,latitude,longitude, created_at, updated_at) VALUES (#{user_info.id},'#{USERS_POSTGRES_CONNECTION.escape_string(user_info.title)}','#{USERS_POSTGRES_CONNECTION.escape_string(about)}','#{USERS_POSTGRES_CONNECTION.escape_string(user_info.name)}','#{USERS_POSTGRES_CONNECTION.escape_string(location)}','#{user_info.location_id}',#{oid},#{user_info.public_service},#{user_info.latitude},#{user_info.longitude}, NOW(), NOW()) RETURNING *"):
      #     (user_info.public_service)?postgres_exec("INSERT INTO user_infos (id, title,about,name,picture,public_service,created_at, updated_at) VALUES (#{user_info.id},'#{USERS_POSTGRES_CONNECTION.escape_string(user_info.title)}','#{USERS_POSTGRES_CONNECTION.escape_string(about)}','#{USERS_POSTGRES_CONNECTION.escape_string(user_info.name)}',#{oid},#{user_info.public_service},NOW(), NOW()) RETURNING *"):
      #         postgres_exec("INSERT INTO user_infos (id, title,about,name,picture,public_service,latitude,longitude,created_at, updated_at) VALUES (#{user_info.id},'#{USERS_POSTGRES_CONNECTION.escape_string(user_info.title)}','#{USERS_POSTGRES_CONNECTION.escape_string(about)}','#{USERS_POSTGRES_CONNECTION.escape_string(user_info.name)}',#{oid},#{user_info.public_service},#{user_info.latitude},#{user_info.longitude}, NOW(), NOW()) RETURNING *")

      result_response = postgres_exec(query)
      result_response.each do|res|
        result = from_postgres_user_info(res)
      end
    end

    result

  end




  def set_insert_query(user_info)

    oid = (user_info.picture)? user_info.picture.identifier.to_i : -1

    about = (user_info.about && !user_info.about.empty?)?
        (user_info.about.length == 1)? user_info.about.map {|str| "\"#{str} .\""}.join(','):
            user_info.about.map {|str| "\"#{str}\""}.join(',') : ''
    # about = (user_info.about && !user_info.about.empty?)?  user_info.about : Array.new
    about = '{'+about+'}'

    location = user_info.location && !user_info.location.empty? ? user_info.location.to_json : nil
    user_location = user_info.latitude && user_info.latitude.to_s && !user_info.latitude.to_s.empty? ? user_info.latitude : nil



    str = "INSERT INTO user_infos (id, about,name ,created_at, updated_at,public_service"

    str = (location)? "#{str},location, location_id" : str
    str = (user_location)? "#{str},latitude,longitude" : str

    str = "#{str}) VALUES (#{user_info.id},'#{about}','#{USERS_POSTGRES_CONNECTION.escape_string(user_info.name)}',NOW(), NOW(),#{user_info.public_service}"
    str = (location)? "#{str} ,'#{USERS_POSTGRES_CONNECTION.escape_string(location)}','#{user_info.location_id}'" : str
    str = (user_location)? "#{str} ,#{user_info.latitude},#{user_info.longitude}" : str
    str = "#{str}) RETURNING * "

    str
  end



  def set_upate_query(user_info)
    oid = (user_info.picture)? user_info.picture.identifier.to_i : -1

    about = (user_info.about && !user_info.about.empty?)?
    (user_info.about.length == 1)? user_info.about.map {|str| "\"#{str} .\""}.join(','):
        user_info.about.map {|str| "\"#{str}\""}.join(',') : ''
    # about = (user_info.about && !user_info.about.empty?)?  user_info.about : Array.new
    about = '{'+about+'}'


    location = user_info.location && !user_info.location.empty? ? user_info.location.to_json : nil
    # user_location = user_info.latitude && !user_info.latitude.empty? ? user_info.latitude : nil
    # puts "UPDATE user_infos SET id=#{user_info.id}, title='#{user_info.title}',about='#{about}',name='#{user_info.name}',picture=#{oid},updated_at=NOW()"
    user_location = user_info.latitude && user_info.latitude.to_s && !user_info.latitude.to_s.empty? ? user_info.latitude : nil

    str = "UPDATE user_infos SET about='#{about}',public_service = #{user_info.public_service}, updated_at=NOW()"

    str = (location)? "#{str}, '#{USERS_POSTGRES_CONNECTION.escape_string(location)}',location_id='#{user_info.location_id}" : str
    str = (user_location)? "#{str}, latitude = #{user_info.latitude},longitude = #{user_info.longitude}" : str

    str = "#{str} WHERE id=#{user_info.id} RETURNING *"


    str


  end

  def update_pg_info(user_info)
    result = nil

    query = set_upate_query(user_info)

    result = postgres_exec(query)
    # puts "QUERY EXEC !!! #{query.inspect}"
    result.each do|res|
      result = from_postgres_user_info(res)
    end
    #
    #
    result
    #

  end



  def update_pg_keywords_rated (user_info)

    result = nil
    # puts "UPDATE user_infos SET keywords_rated= '#{user_info.keywords_rated.to_json}' , updated_at=NOW() WHERE id=#{user_info.id}"
    result_response =  postgres_exec("UPDATE user_infos SET keywords_rated='#{user_info.keywords_rated.to_json}' , updated_at=NOW() WHERE id=#{user_info.id} RETURNING *")
    result_response.each do|res|
      result = from_postgres_user_info(res)
    end
    result
  end




  def get_pg_user_info(uid)

    user_info = nil
    if uid
      result2 = postgres_exec("SELECT * FROM user_infos WHERE id=#{uid}")

      result2.each do |row|
        user_info = UserInfo.new
        user_info.from_postgres(row)
        user_info
      end
    end
    user_info
  end


  def pg_locations_nearby(sw_ne_points)

    sql = "SELECT * FROM user_infos WHERE "
    condition_sql = within_bounding_box(sw_ne_points[0],sw_ne_points[1],sw_ne_points[2],sw_ne_points[3],'latitude','longitude')

    users_nearby = Array.new

    users_ids = Array.new
    result2 = postgres_exec(sql+condition_sql)
    result2.each do |row|
      user_info = UserInfo.new
      user_info.from_postgres(row)
      users_ids << user_info.id.to_s
      users_nearby << user_info
    end

    {:users_nearby => users_nearby, :users_ids => users_ids }
  end


  def from_postgres_user_info(record)
    user_info = UserInfo.new
    user_info.from_postgres(record)
    user_info
  end





  def from_json_load(search_combined)

    first_parse =  search_combined.to_s.gsub('\\\\"', '"')

    first_parse = first_parse.gsub('\\"', '"')
    first_parse = first_parse.gsub('\\\"', '"')
    first_parse = first_parse.gsub('\\\"', '"')

    json_result = (search_combined.to_s.gsub('\"', '"')).to_json
    if (!search_combined ||  search_combined.empty? || !search_combined[0] || search_combined[0]=="{}"|| search_combined[0]=="{[]}" )
      json_result = [{}]
    else
      json_result = JSON.parse(search_combined[0].gsub('{"[', '[').gsub(']"}', ']').gsub('\"', '"'))
      json_result
    end

    json_result

  end





end