class SessionReplicasController < ApplicationController
  before_action :set_session_replica, only: [:show, :edit, :update, :destroy]

  # GET /session_replicas
  # GET /session_replicas.json
  def index
    @session_replicas = SessionReplica.all
  end

  # GET /session_replicas/1
  # GET /session_replicas/1.json
  def show
  end

  # GET /session_replicas/new
  def new
    @session_replica = SessionReplica.new
  end

  # GET /session_replicas/1/edit
  def edit
  end

  # POST /session_replicas
  # POST /session_replicas.json
  def create
    @session_replica = SessionReplica.new(session_replica_params)

    respond_to do |format|
      if @session_replica.save
        format.html { redirect_to @session_replica}
        format.json { render :show, status: :created, location: @session_replica }
      else
        format.html { render :new }
        format.json { render json: @session_replica.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /session_replicas/1
  # PATCH/PUT /session_replicas/1.json
  def update
    respond_to do |format|
      if @session_replica.update(session_replica_params)
        format.html { redirect_to @session_replica}
        format.json { render :show, status: :ok, location: @session_replica }
      else
        format.html { render :edit }
        format.json { render json: @session_replica.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /session_replicas/1
  # DELETE /session_replicas/1.json
  def destroy
    @session_replica.destroy
    respond_to do |format|
      format.html { redirect_to session_replicas_url }
      format.json { head :no_content }
    end
  end



  def self.vote(user_id,user_name, session, new_vote,votes)
    replica  = SessionReplica.new

    # puts "NEW VOTE????? #{new_vote} WITH #{votes.inspect}"
    replica.start_date = session.start_date_time
    replica.origin_id = session.id
    replica.lactic_session = session
    if new_vote
      # puts "NEW VOTES "
      replica.new_vote(user_id,user_name)
    else
      # puts "UPDATING VOTES "
      replica.update_votes(user_id,user_name,votes)
    end
    # puts "RESULT UPDATE VOTE SESSION REPLICA CONTROLLER  #{replica.inspect}"


  end

  def self.comment(user, session, new_comment, new_replica)
    replica  = SessionReplica.new

    replica.start_date = session.start_date_time
    replica.origin_id = session.id
    replica.lactic_session = session
    if new_replica

      replica.new_comment(user,new_comment)
    else

      replica.update_comments(user,new_comment,session.comments)
    end


    end


  def self.invite(user, session,invitees_ids, new_replica,invitees_hash)
    replica  = SessionReplica.new
    # invitees_hash = Hash[session.invitees.map(&:values).map(&:flatten)]
    invitees = []
    hash = {}
    update = false
    invitees_ids.each do |invitee_id|
      hash[invitee_id] = user.id

      ## check if a new invitee added ....
      # puts "CHECK IF LAREADY INVITED #{invitee_id} ??? in #{invitees_hash.inspect}"
      update = (new_replica) ?  update : !invitees_hash[invitee_id]  || update
      # puts "UPDATE #{update}"
    end
    invitees << hash
    replica.start_date = session.start_date_time
    replica.origin_id = session.id
    replica.lactic_session = session

    # puts "INVITEES HASH ARRAY #{invitees.inspect}"
    if new_replica

      replica.new_invitees(invitees)
    else

      (update)? replica.update_invitees(invitees,session.invitees) : replica

    end


  end


  def self.new_replica_info( lactic_session )

    replica_model = SessionReplica.new
    replica_model.lactic_session = lactic_session

    replica_model.new_replica_info

  end

  def self.update_replica_info( id,lactic_session)
    replica_model = SessionReplica.new

    replica_model.id = id
    replica_model.lactic_session = lactic_session
    replica_model.update_info

  end

  def self.get_replica_by_origin(origin_id,start_date)
    replica_model = SessionReplica.new
    replica_model.get_by_origin(origin_id,start_date)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_session_replica
      @session_replica = SessionReplica.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def session_replica_params
      params.require(:session_replica).permit(:origin_id, :start_date)
    end
end
