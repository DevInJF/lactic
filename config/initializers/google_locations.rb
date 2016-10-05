# GOOGLE_LOCATIONS_CONFIG = YAML.load_file("#{::Rails.root}/config/google_locations.yml")[::Rails.env]


::GOOGLE_LOCATIONS_CLIENT = GooglePlaces::Client.new(ENV['GOOGLE_LOCATIONS_API_KEY'])
# ::GOOGLE_LOCATIONS_CLIENT = GooglePlaces::Client.new('AIzaSyBqRpXKwQorf0DWIq89gWOpDw_SdrZEl8c')