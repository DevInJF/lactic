# uri = URI.parse(ENV["REDIS_URL"] || "redis://localhost:6379/" )
# REDIS  = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)


ENV["REDISTOGO_URL"] ||= "redis://localhost:6379"


Sidekiq.configure_server do |config|
  config.redis = {:url => ENV["REDISTOGO_URL"], :size => 5}
end

Sidekiq.configure_client do |config|
  config.redis = {:url => ENV["REDISTOGO_URL"], :size => 30}
end

#
# Sidekiq.configure_server do |config|
#   config.redis = { url: ENV["REDISTOGO_URL"] }
# end
#
# Sidekiq.configure_client do |config|
#   config.redis = { url: ENV["REDISTOGO_URL"] }
# end

# Sidekiq.configure_server do |config|
#   config.redis = { url: ENV["REDISTOGO_URL"] }
#
#   database_url = ENV['DATABASE_URL']
#   if database_url
#     ENV['DATABASE_URL'] = "#{database_url}?pool=50"
#     ActiveRecord::Base.establish_connection
#   end
#
# end
#
#
# Sidekiq.configure_client do |config|
#   config.redis = { url: ENV["REDISTOGO_URL"] }
# end