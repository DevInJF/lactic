class UserMailer < ActionMailer::Base
  default :from => "sharonanachum@gmail.com"

  def registration_confirmation(user)
    @user = user
    attachments.inline['search_engine_skills.JPG'] = { content: File.read("#{Rails.root}/app/assets/images/search_engine_skills.JPG"),
                                   mime_type: "image/jpg" }
    # mail.attachments.inline['search_engine_skills.JPG'] = File.read('search_engine_skills.JPG')
    mail(:to => "#{user.name} <#{user.email}>", :subject => "Registration Confirmation")
  end

end