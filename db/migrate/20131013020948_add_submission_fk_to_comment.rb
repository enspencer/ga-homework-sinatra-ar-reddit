class AddSubmissionFkToComment < ActiveRecord::Migration
  def up
  	add_column :comments, :submission_id, :integer
  end

  def down
  	remove_column :comments, :submission_id, :integer
  end
end
