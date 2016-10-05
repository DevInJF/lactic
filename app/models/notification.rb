
class Notification < ActiveRecord::Base
  attr_accessor :notifier, :message
  attr_accessor :current_user_notifier
  attr_accessor :notification_type




  include PostgresNotifications


  def get_notifications(notification_id, month_date=DateTime.now)
    # PostgresNotifications.get_notifications(user_id)
    get_pg_notifications(notification_id,month_date)
  end

  def reset_notifications(notification_id, month_date=DateTime.now)
    reset_pg_notifications(notification_id,month_date)
  end

  def new_notification(notifier, message, type, url)
    result = nil

    current_queue = (self.queue)? self.queue.clone : Array.new
    if self.id
      hash = Hash.new
      hash[Time.zone.now.to_s] = {:notifier_id => notifier.id, :notifier_name => notifier.name,:notifier_picture => notifier.picture, :message =>(message), :url => url}
      self.queue  = (current_queue && !current_queue.empty?) ? current_queue : Array.new
      self.queue << hash
      # result = (current_queue && !current_queue.empty?)? update_pg(self, type) : new_pg_notification(self,type)

      puts "NEW NOTIFICATION #{self.inspect}"
      next_month = (Date.today + 1.months).at_beginning_of_month
      this_month = (Date.today).at_beginning_of_month
      result =  notification_upsert(self,type)

      puts "NEW NOTIFICATION RESULT #{result.inspect}"
    end

    # puts "NEW NOTIFICATION RESULT #{result.inspect}"
    result

  end

  def self.form_notification_date_id(user_id)
    notification_date_id = nil
    puts "SETTING NOTIFICATION DATE ID"
    if user_id && user_id.to_i !=0
      d = DateTime.now
      date_int = d.strftime("%m%Y").to_i
      id = "#{user_id}#{date_int}"
      puts "SETTING NOTIFICATION DATE ID ===== #{id}"
      notification_date_id = id.to_i
    end
    puts "SETTING NOTIFICATION DATE ID =====?????  #{notification_date_id}"
    notification_date_id
  end



  def subscribe_to_keyword(keyword,uid, user_info_options = {})

    if NotificationsHelper.is_presence_channel(keyword)
      keywordChannle = ::PUSHER[keyword]
    end
  end


  def auth_channel(channel_name)
    ::PUSHER.authenticate('presence-'+channel_name, params[:socket_id],
                          user_id: cookies[:osm_respond_id],
                          user_info: {name: cookies[:lactic_name],
                                      email: cookies[:email]} # optional
    )
  end


  # def curret_channel_users(channel_name)
  #   Pusher.channel_users(channel_name)
  # end

  def from_hash(notification_hash)

    # notification = nil

    # puts "NOTIFICATION RECORD HASH #{notification_hash.inspect}"
    if notification_hash
      # notification = Notification.new
      self.id = notification_hash["id"].to_i
      self.created_at = Time.zone.parse(notification_hash["created_at"].to_s).to_datetime
      self.updated_at = Time.zone.parse(notification_hash["updated_at"].to_s).to_datetime
      self.requests = notification_hash["requests"].to_i
      self.users = notification_hash["users"].to_i
      self.invites = notification_hash["invites"].to_i
      self.timeline = notification_hash["timeline"].to_i
      self.month_date =(notification_hash["month_date"])?  Time.zone.parse(notification_hash["month_date"].to_s).to_datetime : nil

      self.queue = (self.month_date)? Notification.from_json_load(notification_hash["queue"]) : Array.new

    end
    # notification
  end
  def self.from_json_load(search_combined)

    json_result = nil

    if search_combined

      first_parse =  search_combined.to_s.gsub('\\\\"', '"')

      first_parse = first_parse.gsub('\\"', '"')
      first_parse = first_parse.gsub('\\\"', '"')
      first_parse = first_parse.gsub('\\\"', '"')

      json_result = (search_combined.to_s.gsub('\"', '"')).to_json
      if (!search_combined ||  search_combined.empty? || search_combined=="{}"|| search_combined=="{[]}" )
        json_result = [{}]
      else
        # puts "PARSING TO JSON #{search_combined.gsub('{"[', '[').gsub(']"}', ']').gsub('\"', '"')}"
        json_result = JSON.parse(search_combined.gsub('{"[', '[').gsub(']"}', ']').gsub('\"', '"'))
        json_result
      end
    end

    json_result

  end




end