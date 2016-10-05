require 'crack/json'


module PostgresSessionsRetrieves
  include PostgresHelper
  def save_pg_last_fetch(sessions,hashed_sessions,uid,contacts_sessions,month_date)
    result = false
    result3 = false

    month_time = (month_date)? month_date.utc.strftime('%Y-%m-%d %H:%M:%S.%N'): nil
    month_date = (month_time)? month_date.utc : DateTime.now.utc
    month_time = Time.parse("#{month_date.year}-#{month_date.month}-1").utc.to_datetime
    if uid && month_time

      result2 = postgres_exec("SELECT last_fetch FROM sessions_retrieves WHERE uid='#{uid}' AND contact_sessions=#{contacts_sessions} AND month_date = '#{month_time}'" )
      if !result2 || result2.cmd_tuples()==0
        result3 = postgres_exec("INSERT INTO sessions_retrieves (uid, last_fetch,last_hashed_fetch,contact_sessions,month_date) VALUES ('#{uid}',ARRAY[JSON ('#{USERS_POSTGRES_CONNECTION.escape_string(sessions.to_json.gsub("'", "\\'"))}')],ARRAY[JSON ('#{USERS_POSTGRES_CONNECTION.escape_string(hashed_sessions.to_json.gsub("'", "\\'"))}')],#{contacts_sessions},'#{month_time}')")
      else
        result3 = postgres_exec("UPDATE sessions_retrieves SET last_fetch=ARRAY[JSON ('#{USERS_POSTGRES_CONNECTION.escape_string(sessions.to_json.gsub("'", "\\'"))}')], last_hashed_fetch = ARRAY[JSON ('#{USERS_POSTGRES_CONNECTION.escape_string(hashed_sessions.to_json.gsub("'", "\\'"))}')] WHERE uid='#{uid}' AND contact_sessions=#{contacts_sessions} AND month_date = '#{month_time}'")
      end
    end
    result = result3 && result3.cmd_tuples()!=0
    result
  end

  def delete_pg_session_added(user_uid,month_delete, hash_id,contacts_sessions)

    arr =''
    month_delete_start_month = (month_delete.month==1)? 12 : month_delete.month-1
    month_delete_end_month = (month_delete.month==12)? 1 : month_delete.month+1
    month_start_time = Time.parse("#{month_delete.year}-#{month_delete_start_month}-1").utc.to_datetime
    month_end_time = Time.parse("#{month_delete.year}-#{month_delete_end_month}-1").utc.to_datetime
    result = user_uid && month_start_time && month_end_time
    if result
      result1 = postgres_exec("SELECT * FROM sessions_retrieves WHERE uid='#{user_uid}' AND contact_sessions=#{contacts_sessions} AND (month_date >= '#{month_start_time}' AND month_date <= '#{month_end_time}')" )
      result = result1 && result1.cmd_tuples()!=0
      if result
        result1.each do |row|
          month_arr = add_to_postgres_string_array(row.values_at('deleted_sessions'), hash_id)
          if (month_arr && month_arr!='' && arr!='')
            month_arr = month_arr.gsub('{',',')
            arr = arr.gsub('}','')
            arr = "#{arr}#{month_arr}"
          else
            arr = month_arr
          end
          result2 = (arr && arr!='')? postgres_exec("UPDATE sessions_retrieves SET deleted_sessions='#{arr}' WHERE uid='#{user_uid}' AND contact_sessions=#{contacts_sessions} AND (month_date >= '#{month_start_time}' AND month_date <= '#{month_end_time}')") : nil
          result =  result && result2 && result2.cmd_tuples()!=0
        end
      end
    end
    result
  end

  def delete_pg_last_fetch(user_uid,contacts_sessions,month_date)
    result = false
    month_time = Time.parse("#{month_date.year}-#{month_date.month}-1").utc.to_datetime
    if user_uid && month_time
      result2 = postgres_exec("DELETE FROM sessions_retrieves WHERE uid='#{user_uid}' AND contact_sessions=#{contacts_sessions} AND month_date = '#{month_time}'" )
      result =  result2 && result2.cmd_tuples()!=0
    end
    result
  end


  # 223246951357816
  def last_pg_retrieves(uid,contact_sessions,month_start,month_end)
    result = nil
    month_start_time = (month_start)? month_start.utc.strftime('%Y-%m-%d %H:%M:%S.%N'): nil
    month_end_time = (month_end)? month_end.utc.strftime('%Y-%m-%d %H:%M:%S.%N'): nil

    if uid && month_start_time && month_end_time
      sessions = postgres_exec( "SELECT * FROM sessions_retrieves WHERE uid='#{uid}' AND contact_sessions=#{contact_sessions} AND (month_date >= '#{month_start_time}' AND month_date <= '#{month_end_time}')")
      if sessions  && sessions.cmd_tuples()!=0

        last_fetch_result = Array.new
        last_hashed_fetch_result = Hash.new
        sessions.each do |row|
          if row.values_at('last_fetch')

            last_fetch_result = last_fetch_result.concat(from_row_to_model(row, 'last_fetch',uid,contact_sessions))

            row_hash = from_row_to_model(row, 'last_hashed_fetch',uid,contact_sessions)
            row_hash.each do |key,value|

              last_hashed_fetch_result[key] = value
            end
          end
            # deleted = from_postgres_array_of_string(row.values_at('deleted_sessions'))


          if row.values_at('deleted_sessions') && row.values_at('deleted_sessions')[0]
            deleted_row = JSON.parse(row.values_at('deleted_sessions')[0].gsub('\""', '"').gsub('"\"', '"').gsub('{', '[').gsub('}', ']'))

            deleted = deleted_row

          end

            result = {:last_fetch => last_fetch_result, :last_hashed_fetch_result => last_hashed_fetch_result, :deleted_sessions => deleted }



        end
      end
    end
    result
  end


  def from_postgres_array_of_string(array_from_pg)
    del = array_from_pg[0].gsub(',"{}"','')
    del = del.gsub('{','{"').gsub('}','"}')
    del = del.gsub('\"','"').gsub('""','').gsub('{"','["').gsub('"}','"]')


    del =  del.gsub('\\\\"', '"')

    del = del.gsub('\\"', '"')
    del = del.gsub('\\\"', '"')
    del = del.gsub('\\\"', '"')

    del = (del.gsub('\"', '"'))


    del1 = del.gsub('\\\"', '"')

    del2 = del1.gsub(',', '","')

    deleted = (del && !(del=='{}'))? JSON.parse(del2) : []
    deleted

  end


  def add_to_postgres_string_array(array_from_pg, add_s)
    arr = ''
    if array_from_pg && array_from_pg[0]!="{}"
      deleted = array_from_pg.to_s.gsub('{','').gsub('}','').gsub('["{','[{').gsub('}"]','}]')

      deleted =  deleted.gsub('\\\\"', '"')

      deleted = deleted.gsub('\\"', '"')
      deleted = deleted.gsub('\\\"', '"')
      deleted = deleted.gsub('\\\"', '"')

      deleted = (deleted.gsub('\"', '"'))

      deleted = deleted.gsub('"','')

      deleted.gsub('["','[').gsub('"]',']')


      deleted = deleted.gsub('[','["').gsub(']','"]').gsub(',','","')


      deleted_arr = JSON.parse(deleted)

      deleted_arr << add_s


      deleted_arr = deleted_arr.uniq

      arr = deleted_arr.map { |s| "#{ActiveRecord::Base.connection.quote(s)}" }.join(',')

      arr = '{'+arr+'}'
    else


      array_of_strings = Array.new
      array_of_strings << add_s
      arr = array_of_strings.map { |s| "{#{ActiveRecord::Base.connection.quote(s)}}" }.join(',')

    end
    arr = arr.gsub("'",'\"')
    arr

  end







  def from_row_to_model(row, row_value_column,reuest_id,invite_retrieve)
    hashed =  row_value_column.eql? 'last_hashed_fetch'
    result =  hashed ? Hash.new : Array.new
    last_fetch_json_result = row.values_at(row_value_column)

    last_fetch_to_hash = (last_fetch_json_result)? PostgresHelper.from_postgres_json_load(last_fetch_json_result) : []
    last_fetch_to_hash.each do |hash|
      if hashed
        hash_MERGE = from_postgres(hash,reuest_id,hashed,invite_retrieve)
        hash_MERGE.each do |key,value|
          result[key] = value
        end
      else
        session = from_postgres(hash,reuest_id,hashed,invite_retrieve)
        result << session
      end
    end
    result
  end



  def from_postgres(postgres_record,reuest_id,hashed, invite_retrieve)

    lactic_session = (hashed == true)? LacticSession.from_hashed_hash(postgres_record,reuest_id,invite_retrieve): LacticSession.from_hash(postgres_record,reuest_id,invite_retrieve)
    lactic_session
  end



end


