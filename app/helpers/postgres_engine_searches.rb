
module PostgresEngineSearches
  include PostgresHelper

  def get_pg_keyword_users(keywords)
    result = Array.new
    if keywords && !keywords.empty?
      users = postgres_exec("SELECT users FROM engine_searches WHERE keyword='#{keywords}' " )
      if users
        users.each do |row|
          result = from_postgres(row)
        end
      end
    end
    result
  end

  def get_pg_keywords_users(keywords)
    result = Hash.new
    if keywords.is_a? (String)
      key_arr = keywords.split(',')
    else
      key_arr = keywords
    end
    keys = key_arr.to_json.to_s.gsub('[','').gsub(']','')
    # key_arr = (keywords.is_a?(Array))?  keywords.join(",") : keywords
    if keywords && !keywords.empty?
      # puts "SELECT * FROM engine_searches WHERE keyword = ANY ('{#{keys}}') "
      users = postgres_exec("SELECT * FROM engine_searches WHERE keyword  = ANY ('{#{keys}}') " )
      if users && users.cmd_tuples()!=0
        # puts "FOUND KEYWORDS #{users.inspect}"
        users.each do |row|
          result[row["keyword"]] = from_postgres(row)
        end
      end
    end
    # puts "RESULT #{result.inspect}"
    result
  end



  def get_pg_keywords_users_ids(keywords)
    result = Array.new
    if keywords.is_a? (String)
      key_arr = keywords.split(',')
    else
      key_arr = keywords
    end
    keys = key_arr.to_json.to_s.gsub('[','').gsub(']','')
    # key_arr = (keywords.is_a?(Array))?  keywords.join(",") : keywords
    if keywords && !keywords.empty?
      # puts "SELECT users FROM engine_searches WHERE keyword = ANY ('{#{keys}}') "
      users = postgres_exec("SELECT users FROM engine_searches WHERE keyword  = ANY ('{#{keys}}') " )
      if users && users.cmd_tuples()!=0
        # puts "FOUND KEYWORDS #{users.inspect}"
        users.each do |row|
          users = from_postgres(row)
          users.each do |user_id, name|

            # puts "FOUND user id  #{user_id}"
            user_id.each do |l|
              result << l[0]
            end
            # puts "FOUND name #{name}"
          end

        end

      end
    end
    # puts "RESULT #{result.uniq.inspect}"
    result.uniq
  end


  def update_pg_keyword_users(updated_users, keyword)
    result = nil
    if updated_users
      save_result = postgres_exec("UPDATE engine_searches SET users = ARRAY[JSON('#{updated_users.to_json}')] WHERE keyword='#{keyword}' ")
      result =  save_result && save_result.cmd_tuples()!=0
    end
    # puts "SAVE RESULT FOR UPDATE KEYWORD USERS #{result.inspect}"
    result
  end


  def from_postgres(engine_searches_users)
    User.from_engine_searches(engine_searches_users["users"])
  end



  # def self.postgres_exec(query)
  #
  #   result =  nil
  #
  #   begin
  #     result = USERS_POSTGRES_CONNECTION.exec(query)
  #   rescue PG::Error => err
  #     begin
  #       puts "RESCUE FROM PG POSTGRES EXEC ERROR  query #{query} ===  ERROR ===  #{err.message}"
  #       USERS_POSTGRES_CONNECTION.reset
  #
  #       ActiveRecord::Base.connection.reconnect!
  #     rescue
  #       sleep 10
  #       retry # will retry the reconnect
  #     else
  #       retry # will retry the database_access_here call
  #     end
  #   end
  #   result
  # end
  #



end