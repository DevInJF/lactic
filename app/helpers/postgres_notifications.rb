
module PostgresNotifications

  include PostgresHelper



  def get_pg_notifications(notification_id,month_date=DateTime.now)
    result = nil
    str_id = notification_id.to_s
    if str_id && str_id != '0' && str_id.length > 7

      # id2 = (str_id[0..str_id.length-7]).to_i


      puts "NOTIFICATION ID DATE ==== #{notification_id}"
      # puts "NOTIFICATION ID NO DATE ==== #{id2}"
      this_month_date = (Date.today).at_beginning_of_month
      next_month_date = (Date.today + 1.months).at_beginning_of_month
      notifications = (notification_id)? postgres_exec("SELECT * FROM notifications WHERE id=#{notification_id} AND (month_date  >= '#{this_month_date}' AND month_date  <= '#{next_month_date}')"):nil

    if  (notifications && notifications.cmd_tuples()!=0)
      notifications.each do |row|
        result = from_postgres(row)
      end
    end
    end
    # puts "NOTIFICATION FROM  HASH RETURNED RESULT #{result.inspect}"

    result
  end


  def reset_pg_notifications(notification_id,month_date=DateTime.now)
    #   UPDATE Orders SET Quantity = Quantity + 1 WHERE
    result = nil
    # puts "UPDATE notifications SET #{type}=#{type}+1, updated_at = NOW(), queue =ARRAY[JSON ('#{notification.queue.to_json}')] WHERE id=#{notification.id} "
    this_month_date = (Date.today).at_beginning_of_month
    next_month_date = (Date.today + 1.months).at_beginning_of_month
    if notification_id && notification_id.to_i != 0
      notifications = postgres_exec("UPDATE notifications SET requests=0,invites=0,timeline=0,users=0, updated_at = NOW()  WHERE id=#{notification_id} AND (month_date  >= '#{this_month_date}' AND month_date  <= '#{next_month_date}') ")

      result = notifications &&  notifications.cmd_tuples()!=0
    end

    result
  end


  def update_pg(notification, type)
  #   UPDATE Orders SET Quantity = Quantity + 1 WHERE
    result = nil
    # puts "UPDATE notifications SET #{type}=#{type}+1, updated_at = NOW(), queue =ARRAY[JSON ('#{notification.queue.to_json}')] WHERE id=#{notification.id} "
    this_month_date = (Date.today).at_beginning_of_month
    next_month_date = (Date.today + 1.months).at_beginning_of_month
    if notification && type && notification.id
      notifications = postgres_exec("UPDATE notifications SET #{type}=#{type}+1, updated_at = NOW(), queue =ARRAY[JSON ('#{USERS_POSTGRES_CONNECTION.escape_string(notification.queue.to_json)}')] WHERE id=#{notification.id} AND (month_date  >= '#{this_month_date}' AND month_date  <= '#{next_month_date}') ")
      if notifications &&  notifications.cmd_tuples()!=0
        # notifications.each do |row|
        #   result = PostgresNotifications.from_postgres(row)
        # end
        notification.month_date = (Date.today).at_beginning_of_month

        result = notification
      end
    end
    result
  end




  def notification_upsert(notification,type)
    result = nil
    # puts " WITH upsert AS (UPDATE notifications SET , updated_at = NOW(), #{type}=#{type}+1  WHERE id=#{notification.id} RETURNING *)
    #       INSERT INTO notifications (id, #{type}, created_at, updated_at, queue) VALUES (#{notification.id},1, NOW(), NOW(), WHERE NOT EXISTS (SELECT * FROM upsert);"

    this_month_date = (Date.today).at_beginning_of_month
    next_month_date = (Date.today + 1.months).at_beginning_of_month
    if notification && notification.id
      # puts "NOTIFICATION UPSERT  ==== #{notification.id}"
      sql = " WITH upsert AS (UPDATE notifications SET queue=ARRAY[JSON ('#{USERS_POSTGRES_CONNECTION.escape_string(notification.queue.to_json)}')], updated_at = NOW(), #{type}=#{type}+1  WHERE id=#{notification.id} AND (month_date  >= '#{this_month_date}' AND month_date  <= '#{next_month_date}') RETURNING *)
          INSERT INTO notifications (id, #{type}, created_at, updated_at, queue, month_date) SELECT #{notification.id},1, NOW(), NOW(),ARRAY[JSON ('#{USERS_POSTGRES_CONNECTION.escape_string(notification.queue.to_json)}')], '#{(Date.today).at_beginning_of_month}' WHERE NOT EXISTS (SELECT * FROM upsert);"

      notifications = postgres_exec(sql)
      # puts "NOTIFICATION POSTGRES RESULT #{notifications.inspect}"
      # puts "NOTIFICATION POSTGRES RESULT STATUS 1#{notifications.cmd_status()}"
      # puts "NOTIFICATION POSTGRES RESULT STATUS 2#{notifications.cmd_status}"
      if notifications
        # && notifications.cmd_status() == USERS_POSTGRES_CONNECTION::Constants::PGRES_COMMAND_OK
        # notifications.each do |row|
        #   result = PostgresNotifications.from_postgres(notifications)
        # end
        notification.month_date = (Date.today).at_beginning_of_month
        result = notification
        # puts "NOTIFICATION POSTGRES RESULT IN!!!!  #{notifications.cmd_status.inspect}"

      end

    end

    result
  end




  def new_pg_notification(notification, type)
    result = nil
    this_month_date = (Date.today).at_beginning_of_month
    next_month_date = (Date.today + 1.months).at_beginning_of_month
    if notification && type && notification.id
      notifications = postgres_exec("INSERT INTO notifications (id, #{type}, created_at, updated_at, queue, month_date) VALUES (#{notification.id},1, NOW(), NOW(),ARRAY[JSON ('#{USERS_POSTGRES_CONNECTION.escape_string(notification.queue.to_json)}')],'#{this_month_date}')")
      if notifications &&  notifications.cmd_tuples()!=0
        # notifications.each do |row|
        #   result = PostgresNotifications.from_postgres(row)
        # end
        notification.month_date = (Date.today).at_beginning_of_month

        result = notification
      end
    end
    result
  end


  def from_postgres(notification_record)
    # puts "FROM POSTGRES NOTOFOCtio  RECORD HASH #{notification_record.inspect}"

    notification = Notification.new
    notification.from_hash(notification_record)
    # puts "NOTIFICATION FROM  HASH RETURNED #{notification.inspect}"

    notification
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

  # def self.postgres_exec(query)
  #   result =  nil
  #
  #   begin
  #     result = USERS_POSTGRES_CONNECTION.exec(query)
  #   rescue PG::Error => err
  #     begin
  #       puts "RESCUE FROM PG SAVE POSTGRES NOTIFICATIONS #{err.message}"
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



end