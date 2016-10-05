json.array!(@lactic_sessions) do |lactic_session|
  json.extract! lactic_session, :id, :title, :description, :start_date_time, :end_date_time, :location, :location_id, :duration, :week_day, :creator_fb_id, :shared
  json.url lactic_session_url(lactic_session, format: :json)

  # json.start lactic_session.start_date_time.getlocal(@utc_offset)
  json.start lactic_session.start_date_time
  # json.start Time.zone.parse(lactic_session.start_date_time.to_s).to_datetime.getlocal(@utc_offset)
  # json.start @zone_info.utc_to_local(lactic_session.start_date_time)
  # json.end lactic_session.end_date_time.getlocal(@utc_offset)
  json.end lactic_session.end_date_time || lactic_session.start_date_time
  json.month_view_date lactic_session.month_view_date
  json.year_view_date lactic_session.year_view_date
  # json.end Time.zone.parse(lactic_session.end_date_time.to_s).to_datetime.getlocal(@utc_offset)
  # json.month_view_date DateTime.now.month
  json.url lactic_session_url(lactic_session, format: :html)

end

# json.array!(@osm_sessions) do |osm_session|
#   json.extract! osm_session,  :title, :description, :location, :location_id, :shared, :user_vote, :osm_id, :uid
#   json.osm_id osm_session.osm_id
#   json.id osm_session.osm_id
#   # json.start (osm_session.end_date_time).rfc822
#   json.start osm_session.start_date_time.getlocal()
#   # json.start (osm_session.start_date_time).rfc822
#   json.end osm_session.end_date_time.getlocal()
#   json.month_view_date '11'
#   json.url osm_session_url(osm_session, format: :html)
# end
