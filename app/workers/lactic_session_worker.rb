class LacticSessionWorker
  include Sidekiq::Worker

  def perform(month,year,uid, matched_uid)

    # backgroundOut = OsmSessionsController.setup_monthly_schedule(month,year,uid,matched_uid)


    # OsmSession.save_last_fetch(backgroundOut,uid)

    # puts "IN WORKER!!!!!"
    # Sidekiq.logger.warn "IN WORKER!!!!!"


    # redirect_to url_for(:controller => :osm_sessions, :action => callback, :outs => backgroundOut)
    # redirect_to osms_path(:outs => backgroundOut)


  end

end
