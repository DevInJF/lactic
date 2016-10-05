class HomesController < LacticSessionsCommonController

  before_action :notification_center, only: [ :index]


  def index_2

    @current_user_id = cookies[:osm_respond_id]
    if cookies[:osm_respond_id] == '10153011850791938'
      sharon_index(params)
    else

      current_user = get_current_session_user
      day = params[:day] || 1
    # puts "CALLING INDEX HOME WITH DAY #{day}"
    case day.to_i
      when 1
        lactic_sessions_promoted = get_all_between(0.days.ago.beginning_of_day,0.days.from_now.end_of_day,current_user,current_user)
      when 2
        lactic_sessions_promoted =  get_all_between(1.days.from_now.beginning_of_day,1.days.from_now.end_of_day,current_user,current_user)
      when 3
        lactic_sessions_promoted =  get_all_between(2.days.from_now.beginning_of_day,2.days.from_now.end_of_day,current_user,current_user)
      when 4
        lactic_sessions_promoted =  get_all_between(3.days.from_now.beginning_of_day,3.days.from_now.end_of_day,current_user,current_user)
      when 5
        lactic_sessions_promoted =  get_all_between( 4.days.from_now.beginning_of_day,4.days.from_now.end_of_day,current_user,current_user)
      when 6
        lactic_sessions_promoted =  get_all_between( 5.days.from_now.beginning_of_day,5.days.from_now.end_of_day,current_user,current_user)
      when 7
        lactic_sessions_promoted = get_all_between( 6.days.from_now.beginning_of_day,6.days.from_now.end_of_day,current_user,current_user)
      else
        lactic_sessions_promoted = []
        # OsmSession.all
    end

    @lactic_sessions = (lactic_sessions_promoted && lactic_sessions_promoted[:sessions])? lactic_sessions_promoted[:sessions]: []

    @lactic_sessions_hash = (lactic_sessions_promoted && lactic_sessions_promoted[:hash_sessions])? lactic_sessions_promoted[:hash_sessions]: []

    ## creating session from the timeline
    @lactic_session = LacticSession.new
    @repeat_options =  [["Weekly",0],["Once",1]]


    end
  end



  def index
    @user = get_current_user_from_cookie
    @current_user_id = cookies[:osm_respond_id]
    day = params[:day].to_i || 1


    @week_lactic_sessions = get_global_var(@current_user_id)[:weekly_sessions]
    @lactic_sessions_hash = get_global_var(@current_user_id)[:hash_sessions]
    @lactic_sessions = (@week_lactic_sessions[day])? @week_lactic_sessions[day] : Array.new

    @lactic_session = LacticSession.new
    @repeat_options =  [["Weekly",0],["Once",1]]


    # if cookies[:osm_respond_id] == '10153011850791938'


      # @lactic_requests = LacticMatchesController.get_mock_requets

      @lactic_suggestions = contacts(true)
    # end



    end

  def show
    # puts "PARAMS SHOW #{params.inspect}"
  end





end
