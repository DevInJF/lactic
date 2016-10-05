module PostgresHelper



  def self.json_load(search_combined)

    json_result = Array.new

    if !search_combined || search_combined.empty?
      json_result = Array.new
    else
      # puts "SEARCH COMBINED #{search_combined[0..120]}"
      json_result = JSON.parse(search_combined)
    end
    json_result

  end


  def self.from_postgres_json_load(json_load)
    json_result = Array.new

    if (!json_load ||  json_load.empty? || !json_load[0] || json_load[0]=="{}"|| json_load[0]=="{[]}" )
      json_result = [{}]
    else

      json = json_load[0].gsub('\"', '"')
      json = (json).gsub('{""[{', '[{').gsub('}]""}', '}]').gsub('{"[{', '[{').gsub('}]"}', '}]')
      j = (json).gsub('\"', '"')
      j = (j).gsub('\"', '"').gsub('\\\n', '')

      j = unescape_from_postgres(j)

      j1 = Crack::JSON.parse(j.to_json)

      json_result = JSON.parse(j1)
    end

    json_result

  end



  def self.from_array_string_load(search_combined)

    result = Array.new
    if (!search_combined ||  search_combined.empty? || !search_combined[0] || search_combined=="{}"|| search_combined=="{[]}" )
      result = Array.new
    else
      result = JSON.parse(search_combined.gsub('{', '[').gsub('}', ']').gsub('\"', '"'))

    end

    result

  end
  def self.escape_for_postgres(str)

    (str && !str.empty?)? str.gsub("'",'%q').gsub("\t",' ') : ''
  end


  def self.unescape_from_postgres(str)
    str = (str && !str.empty?)? str.gsub('%q',"'").gsub("\t",' ') : ''
    str = (str && !str.empty?)? str.gsub('\\\\u0026',"&").gsub("\t",' ') : ''
  end

  def self.escape_title_descriptions(str)
    str = (str && !str.empty?)? str.gsub("'",'%q').gsub("\t",' ') : ''
    # str = str.gsub(",",'%l')
    # str = str.gsub("&",'%l')
    str
  end
  def self.unescape_title_descriptions(str)
    str = (str && !str.empty?)? str.gsub('%q',"'") : ''
    str = (str && !str.empty?)? str.gsub('\\\\u0026',"&") : ''
    # str = str.gsub('%l',",")
    # str = str.gsub("&",'%l')
    str
  end
  def get_pg_access
    @@semaphore ||= Mutex.new
    # @@semaphore
  end

  def postgres_exec(query)
    get_pg_access
    # Thread.new {
      @@semaphore.synchronize {
    result =  nil

    begin
      result = USERS_POSTGRES_CONNECTION.exec(query)
    rescue PG::Error => err
      begin
        puts "RESCUE FROM PG SAVE POSTGRES NOTIFICATIONS #{err.message}"
        USERS_POSTGRES_CONNECTION.reset

        ActiveRecord::Base.connection.reconnect!
      rescue
        sleep 10
        retry # will retry the reconnect
      else
        retry # will retry the database_access_here call
      end
    end
    result
    }
    # }
  end

end
