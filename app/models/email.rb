class Email < ActionMailer::Base
  default from: "lacticinc@gmail.com"

  attr_accessor :to

  def email_notification(user,email_type='',notifications=Array.new)
    @user = user
    @user.name = @user.name.gsub('%q',"'")
    @email_type = (email_type && !email_type.empty?)? email_type : 'email_notification_center'
    @email_notification_send = true

    case @email_type
      when 'email_new_features'
        new_features
      when 'email_sharon'
        email_sharon
      when 'email_lactic_create'
        lactic_create
      when 'email_lactic_partner'
        lactic_partner
      else
        @email_type = 'email_notification_center'
        @full_email_notifications = (notifications)? notifications.queue : Array.new
        @email_notifications = Array.new

        1.upto(4) do |x|
          if @full_email_notifications.length - x >= 0
            @email_notifications[x-1] =  @full_email_notifications[@full_email_notifications.length-x]
          end
        end

        mail(to: @user.email, subject: 'LACtic Time!')
    end

    # @email_notifications = notifications

  end




  def new_features
    # @user = user
    # @email_notifications = (notifications)? notifications.queue : Array.new

    # @email_notifications = notifications

    attachments.inline['search_engine_1.png'] = { content: File.read("#{Rails.root}/app/assets/images/search_engine_1.png"),mime_type: "image/png" }
    attachments.inline['search_engine_2.png'] = { content: File.read("#{Rails.root}/app/assets/images/search_engine_2.png"),mime_type: "image/png" }
    attachments.inline['search_engine_3.png'] = { content: File.read("#{Rails.root}/app/assets/images/search_engine_3.png"),mime_type: "image/png" }




    # puts "EMAIL drliver  #{DateTime.now}"
    mail(to: @user.email, subject: 'LACtic Time!')
  end

  def lactic_create

    # @email_notifications = (notifications)? notifications.queue : Array.new

    # @email_notifications = notifications
    # @email_notification_send = true
    attachments.inline['user_lactic_session_screenshot.png'] = { content: File.read("#{Rails.root}/app/assets/images/user_lactic_session_screenshot.png"),mime_type: "image/png" }
    attachments.inline['lactic_invite_session_screenshot.png'] = { content: File.read("#{Rails.root}/app/assets/images/lactic_invite_session_screenshot.png"),mime_type: "image/png" }
    attachments.inline['lactic_create_screenshot.png'] = { content: File.read("#{Rails.root}/app/assets/images/lactic_create_screenshot.png"),mime_type: "image/png" }
    attachments.inline['invite_to_session_screenshot.png'] = { content: File.read("#{Rails.root}/app/assets/images/invite_to_session_screenshot.png"),mime_type: "image/png" }
    # attachments.inline['calendar-check.png'] = { content: File.read("#{Rails.root}/app/assets/images/calendar-check.png"),mime_type: "image/png" }




    # puts "EMAIL drliver  #{DateTime.now}"
    mail(to: @user.email, subject: 'LACtic Time!')
  end



  def lactic_partner
    attachments.inline['table-2-hover.jpg'] = { content: File.read("#{Rails.root}/app/assets/images/table-2-hover.jpg"),mime_type: "image/jpg" }
    # attachments.inline['calendar-check.png'] = { content: File.read("#{Rails.root}/app/assets/images/calendar-check.png"),mime_type: "image/png" }
    mail(to: @user.email, subject: 'LACtic Time!')
  end

  def email_sharon
    @email_type = 'email_lactic_partner'
    attachments.inline['table-2-hover.jpg'] = { content: File.read("#{Rails.root}/app/assets/images/table-2-hover.jpg"),mime_type: "image/jpg" }
    # attachments.inline['calendar-check.png'] = { content: File.read("#{Rails.root}/app/assets/images/calendar-check.png"),mime_type: "image/png" }
    mail(to: @user.email, subject: 'Someone viewed Sharon LACtic!')
  end
end