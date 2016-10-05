class DeleteKeywordsRatedFromUserInfos < ActiveRecord::Migration
  def change
    remove_column :user_infos, :keywords_rated, :json, array: true

  end
end
