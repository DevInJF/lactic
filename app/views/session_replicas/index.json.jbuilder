json.array!(@session_replicas) do |session_replica|
  json.extract! session_replica, :id, :origin_id, :start_date
  json.url session_replica_url(session_replica, format: :json)
end
