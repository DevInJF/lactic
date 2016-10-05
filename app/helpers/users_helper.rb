module UsersHelper



  INSTRUCOTRS_KEYWORD = 'instructor'
  DANCERS_KEYWORD = 'dancer'
  MODELS_KEYWORD = 'model'
  GYM_KEYWORD = 'gym'
  STUDIO_KEYWORD = 'studio'
  CROSSFIT_KEYWORD = 'crossfit'


  VALID_KEYWORDS = [INSTRUCOTRS_KEYWORD,DANCERS_KEYWORD,MODELS_KEYWORD,GYM_KEYWORD,STUDIO_KEYWORD,CROSSFIT_KEYWORD]

  def self.is_valid_keyword(keyword)
    VALID_KEYWORDS.include? keyword
  end


  def self.get_valid_keywords(keywords)
    # puts "CHECK KEYWORDS #{keywords}"
    valid = []
    keywords_arr = (keywords.is_a?(Array)) ? keywords : keywords.split(',')
    # puts "CHECK KEYWORDS 222 #{keywords_arr.inspect}"
    keywords_arr.each do |key|
      if is_valid_keyword(key)
        valid << key
      end
    end
    valid
  end



  # def user_osm_locations
  #
  #   @fb_osm_locations = []
  #   currentUser = UsersController.get_current_session_user
  #   if (currentUser)
  #
  #
  #     access_token = currentUser.oauth_token
  #
  #     #GET graph.facebook.com
  #     #   /search?
  #     # q=sport&
  #     # type=place&
  #     # center=37.76,-122.427&
  #     # distance=1000
  #
  #
  #
  #   end
  #
  #   @fb_osm_locations

  # end



end
