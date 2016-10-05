module NotificationsHelper
  INVITES = "invites"
  DELETE_SESSION = "delete_session"
  USERS = "users"
  SKILL_VOTE = "skill_vote"
  TIMELINE = "timeline"
  REQUESTS = "requests"
  RESPOND = "responds"
  VOTE = "vote"
  COMMENT = "comment"
  JOIN = "join"



  INSTRUCOTRS_CHANNEL = 'instructor'
  DANCERS_CHANNEL = 'dancer'
  MODELS_CHANNEL = 'model'


  PRESENCE_CHANNELS = [INSTRUCOTRS_CHANNEL,DANCERS_CHANNEL,MODELS_CHANNEL]

  def self.is_presence_channel(channel_name)
    PRESENCE_CHANNELS.include? channel_name
  end




    def self.get_message(user, type, added_property=nil)

      case type
        when VOTE
          vote_message(user,added_property)

        when JOIN
          join_message(user)
          # puts 'VOTE NOTIFICATION'
        when COMMENT
          comment_message(user,added_property)
          # puts 'COMMENT NOTIFICATION'
        when INVITES
          # puts 'INVITE NOTIFICATION '
          invite_message(user, added_property)
        when USERS
          # puts 'USERS NOTIFICATION!'
        when TIMELINE
          # puts 'TIMELINE NOTIFICATION'

        when SKILL_VOTE
          # puts 'TIMELINE NOTIFICATION'
          skill_vote_message(user, added_property)

        when REQUESTS
          # puts 'REQUESTS NOTIFICATION'
          request_message(user)
        when RESPOND
          # puts 'RESSPOND NOTIFICATION'
          respond_message(user)
        when DELETE_SESSION
          # puts 'RESSPOND NOTIFICATION'
          delete_message(user,added_property)
        else
          ""
          # puts "UNKNOWN NOTIFICATION"
      end
    end

  def self.vote_message(notifier, session)
    "New vote from #{notifier.name} on #{session.title}"
    end

    def self.delete_message(notifier,session)
    "#{notifier.name} removed #{session.title} from LACtic calendar!"
    end

  def self.comment_message(notifier, session)
    "New comment from #{notifier.name} on #{session.title}"
  end

  def self.invite_message(inviter, session)
    "#{inviter.name} invite you to #{session.title}"
    end


  def self.request_message(inviter)
    "New LActic request from #{inviter.name}"
    end
  def self.respond_message(responder)
    "You and #{responder.name} are now LACticated!"
  end
  def self.join_message(new_user)
    "Your Facebook friend #{new_user.name}, has joined LActic"
  end
  def self.skill_vote_message(inviter, skill)
    "A New vote on your '#{skill}' skill from #{inviter.name}"

  end

end
