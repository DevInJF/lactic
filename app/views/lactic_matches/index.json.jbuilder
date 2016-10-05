json.array!(@lactic_matches) do |lactic_match|
  json.extract! lactic_match, :id, :requestor, :responder, :status, :expires_at, :lactic_id
  json.url lactic_match_url(lactic_match, format: :json)
end
