class LacticMatch < ActiveRecord::Base
  attr_accessor :requestor_name, :responder_name, :status_name, :lactic_id
  attr_accessor :lactic_requests
  attr_accessor :responder_user, :requestor_user

  # attr_accessor :requestor_label, :responder_label, :status_label
  attr_accessor :request_made
  attr_accessor  :responder_uid, :requestor_uid

  include PostgresLacticMatch
  def create_lactic_request(lactic_friend,current_user)

    ## next monday ...
    # days_to_expires_at =  (6-Date.today.wday).abs
    days_to_expires_at = 7 - (Date.today.wday - Date.today.sunday.wday)
    # puts "DAYS TO EXPIRE #{days_to_expires_at}"

    lactic_request = LacticMatch.new
    lactic_request.requestor = current_user
    lactic_request.responder = lactic_friend
    lactic_request.expires_at = DateTime.now.midnight + days_to_expires_at.day


    # puts "EXPIRES DATE #{lactic_request.expires_at}"
    lactic_request.status = LacticMatchesHelper::PENDING

    # PostgresLacticMatch.create_lactic_request(lactic_request,true)
    create_pg_lactic_request(lactic_request,true)

  end


  def request_sent(lactic_request)
    # PostgresLacticMatch.request_sent(lactic_request,true)
    request_pg_sent(lactic_request,true)
  end


  def confirm_request(lactic_request)

    result = nil

    if lactic_request && lactic_request.id
      lactic_request.status = LacticMatchesHelper::ACCEPT
      # result = ParseLacticMatch.update_request_status(lactic_request)
      # result = PostgresLacticMatch.update_request_status(lactic_request)
      result = update_pg_request_status(lactic_request)

      # puts " CONFIRM REQUEST #{result.inspect}"

    end
    result
  end

  # TO DO!!!!!!!!!!!!!
  def reject_request(lactic_friend,current_user)
    lactic_request = LacticMatch.new
    # lactic_request.requestor = current_user
    # lactic_request.responder = lactic_friend
    # lactic_request.status = LacticMatchesHelper::REJECT
    #
    # result = ParseLacticMatch.update_request_status(lactic_request)
    # from_parse(result)
  end



  def get_user_pending_requests
    # PostgresLacticMatch.get_user_pending_requests(self.responder,true)
    get_pg_user_pending_requests(self.responder,true)
  end







end
