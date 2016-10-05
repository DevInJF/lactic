json.array!(@facebooks) do |facebook|
  json.extract! facebook, :id
  json.url facebook_url(facebook, format: :json)
end
