class CreateSubreddits < ActiveRecord::Migration
  def up
  	create_table :subreddits do |t|
  		t.text :topic
  	end
  end

  def down
  	drop_table :subreddits
  end
end
