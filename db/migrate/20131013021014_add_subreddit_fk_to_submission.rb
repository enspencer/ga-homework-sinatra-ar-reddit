class AddSubredditFkToSubmission < ActiveRecord::Migration
  def up
  	add_column :submissions, :subreddit_id, :integer
  end

  def down
  	remove_column :submissions, :subreddit_id, :integer
  end
end
