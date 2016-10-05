class UserInfo < ActiveRecord::Base
  # attr_accessor :title
  attr_accessor :more_about
  attr_accessor :picture_file
  # attr_accessor :location_shared

  attr_accessor :keyword_about, :keyword_service_about
  attr_accessor :keywords_about, :keywords_service_about
  attr_accessor :keywords_rated_hash, :current_keywords
  attr_accessor :keyword, :picked_skill_list_voters
  # mount_uploader :picture, AvatarUploader

  include PostgresUserInfos
  # include PostgresHelper
  # attr_accessor :id
  def from_postgres(postgres_user_info)
    # user = UserInfo.new
    # puts "FROM POSTGRES INFO #{postgres_user_info.inspect}"
    if postgres_user_info

      self.id = postgres_user_info['id'] || ''
      self.name = postgres_user_info['name'] || ''
      self.updated_at = postgres_user_info['updated_at']? postgres_user_info['updated_at'].to_datetime : DateTime.now
      self.title = postgres_user_info['title'] || ''
      if (postgres_user_info['about'])
         postgres_user_info['about'][0] = '['
         postgres_user_info['about'][postgres_user_info['about'].length-1] = ']'


         unescaped_about = PostgresHelper.unescape_from_postgres(postgres_user_info['about'])
      else

      end
      # puts "UNESAPED ABOUT #{unescaped_about}"
      # self.about =(unescaped_about)?  JSON.parse(unescaped_about) : Array.new
      self.about =(unescaped_about)?  PostgresHelper.from_array_string_load(unescaped_about) : Array.new
      self.location = (postgres_user_info['location'] && postgres_user_info['location'] != 'null')? PostgresUserInfos.from_json_load( postgres_user_info['location']) : Hash.new
      self.location_id = postgres_user_info['location_id'] || ''

      self.latitude =  (postgres_user_info['latitude'] && !postgres_user_info['latitude'].empty?)? postgres_user_info['latitude'].to_f : nil
      self.longitude =  (postgres_user_info['longitude'] && !postgres_user_info['longitude'].empty?)? postgres_user_info['longitude'].to_f : nil
      self.public_service =  (postgres_user_info['public_service'])? postgres_user_info['public_service'] : false


      self.keywords_rated = from_json_load(postgres_user_info['keywords_rated'])
      # self.current_keywords = self.keywords_rated


      self.current_keywords = (self.keywords_rated && !self.keywords_rated.empty?)?self.keywords_rated.keys : Array.new

    end
  end
  def from_json_load(search_combined)

    json_result = nil

    # puts "USER INFO KEYWORDS ARRAY #{search_combined}"
    if search_combined

      first_parse =  search_combined.to_s.gsub('\\\\"', '"')

      first_parse = first_parse.gsub('\\"', '"')
      first_parse = first_parse.gsub('\\\"', '"')
      first_parse = first_parse.gsub('\\\"', '"')

      json_result = (search_combined.to_s.gsub('\"', '"')).to_json
      if (!search_combined ||  search_combined.empty? || search_combined=="{}"|| search_combined=="{[]}" )
        json_result = [{}]
      else
        # puts "PARSING TO JSON #{search_combined.gsub('{"[', '[').gsub(']"}', ']').gsub('\"', '"')}"
        json_result = JSON.parse(search_combined.gsub('{"{', '{').gsub('}"}', '}').gsub('\"', '"'))
        json_result
      end
    end

    json_result

  end

  def self.read_image(oid, body)
    lo = USERS_POSTGRES_CONNECTION.lo_open(oid, ::PG::INV_READ)
    while (data = USERS_POSTGRES_CONNECTION.lo_read(lo, 4096))
      body << data
    end
    USERS_POSTGRES_CONNECTION.lo_close(lo)
  end
  def get_user_info
    get_pg_user_info(self.id)
  end


  def set_info_from_view(info,user_about)

    self.about = (user_about && !user_about.empty?)? user_about: Array.new
    if (info["more_about"] && !info["more_about"].empty?)
      about_escaped = PostgresHelper.escape_title_descriptions(info["more_about"])
      self.about << about_escaped
    end
    self.keywords_about = Array.new

    if (info["keywords_about"])
       self.keywords_about = info["keywords_about"].split(",")
    end
    if (info["keywords_service_about"])
       self.keywords_about += info["keywords_service_about"].split(",")
     end
    self.public_service = info["public_service"]
    self.latitude = (info["latitude"])? info["latitude"].to_f : ''
    self.longitude  = (info["longitude"])? info["longitude"].to_f : ''
    self.title = info["title"]
    self.name = (info["name"])? info["name"] : self.name
    self.location = info["location"] || nil
    self.location_id = info["location_id"] || ''

    # puts "SELF FROM VIEW #{self.inspect}"
    # puts "SELF FROM VIEW CURRENT KEYWORDS #{self.current_keywords.inspect}"
    # puts "SELF FROM VIEW CURRENT KEYWORDS #{JSON.parse(self.current_keywords)}"
  end

  def save_new_info
    # PostgresUserInfos.save_new_info(self)

    save_pg_new_info(self)
  end


  def update_info
    # PostgresUserInfos.update_info(self)

    update_pg_info(self)
  end


  def update_keywords_rated(user_vote_id, keywords, user_vote_name='')
    update = false
    if user_vote_id && keywords && !keywords.empty?
      # puts "UPDATE KEYWORDS BEFORE RATED #{self.keywords_rated.inspect}"
      self.keywords_rated ||= Hash.new
      if user_vote_id == self.id
      ## User define his own keywords settings...
        keywords.each do |keyword|
          update =  (!self.keywords_rated[keyword]) || update
          if (!self.keywords_rated[keyword])
            self.keywords_rated[keyword] = Array.new
          end
        end
        # puts "UPDATE KEYWORDS #{self.keywords_rated.inspect}"
      else
      ## Other users vote on keywords
        # keywords.each do |keyword|
        # puts "UPDATING .....#{self.keywords_rated.inspect}"
          if self.keywords_rated && self.keywords_rated[keywords]
            # puts "UPDATING WITH .....#{keywords}"
            final_hash = Hash[*self.keywords_rated[keywords].collect{|h| h.to_a}.flatten]
            # puts "UPDATING WITH FLATTEN.....#{final_hash.inspect}"

            if !final_hash[user_vote_id]
              self.keywords_rated[keywords] << {user_vote_id => user_vote_name }
              update =  true
            end
          end
        # end
      end
    end
    # update = false
    # puts "KEYWORDS TO UPDATE #{self.keywords_rated.inspect}"
    # (update)? PostgresUserInfos.update_keywords_rated(self) : true
    (update)? update_pg_keywords_rated(self) : true
  end


  def remove_about_text(index)
    if self.about && !self.about.empty? && index < self.about.length
      self.about.delete_at(index)
    end
    # PostgresUserInfos.update_info(self)
    update_pg_info(self)
  end

end