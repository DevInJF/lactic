require 'singleton'
class LacticGlobal

  ### SHARED AMONG ALL USERS
  include Singleton

  attr_accessor :last_lactic_locations
  attr_accessor :last_lactic_sessions_fetched
  attr_accessor :last_lactic_sessions_hash_fetched
  attr_accessor :last_lactic_users_fetched
  attr_accessor :last_lactic_user_month_fetch




  # def self._load(locations)
  #   instance.last_lactic_locations = locations
  #   instance
  # end


end