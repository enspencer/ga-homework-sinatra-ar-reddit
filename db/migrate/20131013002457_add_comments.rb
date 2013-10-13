class AddComments < ActiveRecord::Migration
  def up
  	create_table :comments do |t|
  		t.text :body
  		t.timestamps
  		t.integer :upvotes, default: 0
  		t.integer :downvotes, default: 0
  	end
  end

  def down
  	drop_table :comments
  end
end
