json.extract! @lactic_session, :id, :title, :description, :start_date_time, :end_date_time, :location, :location_id, :duration, :week_day, :creator_fb_id, :shared, :created_at, :updated_at
# json.osm_session do
#   json.extract! @lactic_session, :id, :title, :description, :start_date_time, :end_date_time, :location, :location_id, :duration, :week_day, :creator_fb_id, :shared, :created_at, :updated_at
#
#   json.id @lactic_session.id
#   json.start @lactic_session.start_date_time.getlocal()
#   # json.start (osm_session.start_date_time).rfc822
#   json.end @lactic_session.end_date_time.getlocal()
#   json.url lactic_session_url(get_current_session_user.uid,@lactic_session, format: :html)
#
#   # json.style_class (@osm_session.uid == get_current_session_user.uid)? 'fc-event' : 'fc-friend-event'
#
# end