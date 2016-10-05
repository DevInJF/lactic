class LacticMatchesController < LacticLocationsController
  # before_action :set_lactic_match, only: [:show, :edit, :update, :destroy]

  helper_method :get_lactic_invites
  helper_method :lactic_request
  # GET /lactic_matches
  # GET /lactic_matches.json
  def index
    # puts "IN LACTIC INDEX #{params.inspect}"
  end

  # GET /lactic_matches/1
  # GET /lactic_matches/1.json
  def show
    # puts "IN LACTIC SHOW #{params.inspect}"
  end

  # GET /lactic_matches/new
  def new
    # puts "IN LACTIC NEW #{params.inspect}"
    # responder = params[:responder]
    # @lactic_match = LacticMatch.new
    # if (responder)
    #   @lactic_match.responder = responder
    # end

  end

  # GET /lactic_matches/1/edit
  def edit
    # puts "IN LACTIC EDIT #{params.inspect}"
  end

  # POST /lactic_matches
  # POST /lactic_matches.json
  def create
    @lactic_match = LacticMatch.new(lactic_match_params)
    @lactic_match.responder =  params[:lactic_match][:responder_uid]

    requestor = get_current_session_user
    @lactic_match.requestor = requestor.id.to_s
    @lactic_match.status = 'pending'

    # current_user = get_current_session_user

    respond_to do |format|
      result = @lactic_match.create_lactic_request(@lactic_match.responder,@lactic_match.requestor)
      # puts "LACTIC MATCH #{result.inspect}"
      if result && !result.request_made
        # puts "SEND NOTIFICATION..."
        lactic_match_request(requestor,@lactic_match.responder)
        format.html { redirect_to public_profile_path({:id => params[:lactic_match][:responder_uid]}) }
        # format.json { render :show, status: :created, location: @lactic_match }
      else
        format.html { redirect_to public_profile_path({:id => params[:lactic_match][:responder_uid]}) }
        format.json { render json: @lactic_match.errors, status: :unprocessable_entity }
      end
    end
  end


  def quick_create
    @lactic_match = LacticMatch.new
    @lactic_match.responder =  params[:responder]

    requestor = get_current_user_from_cookie
    @lactic_match.requestor = requestor.id.to_s
    @lactic_match.status = 'pending'


    puts "LACTIC QUICK REQUEST TO SEND #{@lactic_match.inspect}"
    # respond_to do |format|
    #   result = @lactic_match.create_lactic_request(@lactic_match.responder,@lactic_match.requestor)
    #   # puts "LACTIC MATCH #{result.inspect}"
    #   if result && !result.request_made
    #     # puts "SEND NOTIFICATION..."
    #     lactic_match_request(requestor,@lactic_match.responder)
    #     format.html {redirect_to :back, :params => params[:url_params]}        # format.json { render :show, status: :created, location: @lactic_match }
    #   else
    #     format.html {redirect_to :back, :params => params[:url_params]}
    #   end
    # end


    respond_to do |format|
      # format.html {redirect_to profile_path }
      format.html {redirect_to :back, :params => params[:url_params]}
    end
  end





  # PATCH/PUT /lactic_matches/1
  # PATCH/PUT /lactic_matches/1.json
  def update
    # puts "IN LACTIC UPDTAE #{params.inspect}"
    # respond_to do |format|
    #   if @lactic_match.update(lactic_match_params)
    #     format.html { redirect_to @lactic_match, notice: 'Lactic match was successfully updated.' }
    #     format.json { render :show, status: :ok, location: @lactic_match }
    #   else
    #     format.html { render :edit }
    #     format.json { render json: @lactic_match.errors, status: :unprocessable_entity }
    #   end
    # end
  end


  def set_lactic_request
    # puts "IN LACTIC LACTIC REQUEST #{params.inspect}"
    result = nil
    responder = params[:responser]
    if (responder)
      # puts " SETING LACTIC REQUEST"
      @lactic_request = LacticMatch.new

      current_user = get_current_session_user
      @lactic_request.requestor = current_user
      @lactic_request.responder = lactic_friend
      # current_user = get_current_session_user

    end
    # result
  end


  def lactic_request

    # lactic_request = params[:lactic_request_id]
    # lactic_request = params[:lactic_request_id]



    # if lactic_request_id
    lactic_request = LacticMatch.new
    lactic_request.id = params[:lactic_request_id]
    lactic_request.requestor_uid = params[:lactic_request_requestor]

    result  = lactic_request.confirm_request(lactic_request)
    # if result

    respond_to do |format|

      if (result && result.responder_user && result.requestor_user)

        # response = User.lacticate_users(result.responder_user, result.requestor_user)
        response = UsersController.lacticate_users(result.responder_user.id, result.requestor_user.id)

        if response

          set_matched_cookie(result.requestor_user.id,true)
          notify_match(lactic_request)
          format.html { redirect_to profile_path }
        else
          format.html { redirect_to profile_path }
        end
        # format.json { render :show, status: :created, location: @lactic_match }
      else
        format.html { redirect_to profile_path }
        puts "ERROR LACTICATE "
        #   format.html { redirect_to profile_path, notice: 'Lactic match was successfully created.' }
      #   # format.json { render json: @lactic_match.errors, status: :unprocessable_entity }
      end
    end
  end


  def self.get_mock_requets

    arr = Array.new
    lactic_match1 = LacticMatch.new
    lactic_match1.requestor = '10154186106742819'
    lactic_match1.requestor_uid = '10154186106742819'
    lactic_match1.requestor_name = 'Idan Maron'
    lactic_match1.status = 'pending'
    lactic_match1.id = 10154186106742819
    arr << lactic_match1
    lactic_match2 = LacticMatch.new
    lactic_match2.requestor = '120336308390801'
    lactic_match2.requestor_uid = '120336308390801'
    lactic_match2.requestor_name = 'Leo Lactic'
    lactic_match2.status = 'pending'
    lactic_match2.id = 120336308390801
    arr << lactic_match2
    lactic_match3 = LacticMatch.new
    lactic_match3.requestor = '124240821263603'
    lactic_match3.requestor_uid = '124240821263603'
    lactic_match3.requestor_name = 'Joe Jensen'
    lactic_match3.status = 'pending'
    lactic_match3.id = 124240821263603
    arr << lactic_match3
    # lactic_match4 = LacticMatch.new
    # lactic_match4.requestor = '280906882262216'
    # lactic_match4.requestor_uid = '280906882262216'
    # lactic_match4.requestor_name = 'Justin Spears'
    # lactic_match4.status = 'pending'
    # lactic_match4.id = 280906882262216
    #
    # arr << lactic_match4


    arr


  end

  def notify_match(lactic_request)
    user_responder = User.new
    user_responder.name = cookies[:lactic_name]
    user_responder.id = cookies[:osm_respond_id].to_i
    user_responder.picture = cookies[:lactic_picture]
    lactic_match_resopnd(user_responder, lactic_request.requestor_uid)
  end
  def self.get_user_pending_requests(user)
    lactic_request = LacticMatch.new
    lactic_request.responder = user.id.to_s
    lactic_request.get_user_pending_requests
  end



  def self.request_sent (lactic_request)
    # LacticMatch.request_sent lactic_request
    lactic_match = LacticMatch.new

    # LacticMatch.request_sent lactic_request
    lactic_match.request_sent lactic_request
  end

  private
    # Use callbacks to share common setup or constraints between actions.


    # Never trust parameters from the scary internet, only allow the white list through.
    def lactic_match_params
      params.require(:lactic_match).permit(:requestor, :responder, :status, :expires_at, :lactic_id)
    end
end
