class CreateSubmissions < ActiveRecord::Migration
  def up
  	create_table :submissions do |t|
  		t.string :link
  		t.text :text
  		t.timestamps
  		t.integer :upvotes, default: 0
  		t.integer :downvotes, default: 0
  	end
  end

  def down
  	drop_table :submissions
  end
end
