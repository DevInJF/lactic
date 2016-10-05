class AddKeywordsRatedFromUserInfosAgain < ActiveRecord::Migration
  def change
    add_column :user_infos, :keywords_rated, :json

  end
end
