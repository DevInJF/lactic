class AddKeywordsRatedToUserInfos < ActiveRecord::Migration
  def change
    add_column :user_infos, :keywords_rated, :json, array: true
  end
end
