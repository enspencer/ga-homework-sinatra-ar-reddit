require 'pry'
require 'pg'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'

set :database, {adapter: 'postgresql',
				database: 'reddit',
				host: 'localhost'}

class Subreddit < ActiveRecord::Base
	has_many :submissions
end

class Submission < ActiveRecord::Base
	belongs_to :subreddit
	has_many :comments
end

class Comment < ActiveRecord::Base
	belongs_to :submission
end

get '/' do
	@subreddits = Subreddit.all
	erb :reddit_index
end

get '/new' do
	@subreddits = Subreddit.all
	@subreddits.order("timestamps DESC")
	erb :subreddit_new
end

get '/newest' do
	@subreddits = Subreddit.all
	@subreddits.order("timestamps DESC")
	erb :reddit_by_newest
end

get '/r/:topic/new' do
	@subreddits = Subreddit.all
	@topic = params[:topic]
	erb :submission_new
end

# trouble with this
get '/r/:topic/newest' do
	@subreddits = Subreddit.all
	topic = params[:topic]
	@subreddit = Subreddit.find_by_topic(params[:topic])
	@subreddit.submissions.order("timestamps DESC")
	erb :subreddit_by_newest
end

# having trouble with this
get '/r/:topic/:submission_id' do
	@subreddits = Subreddit.all
	@topic = params[:topic]
	@submission_id = params[:submission_id]
	@subreddit = Subreddit.find_by_topic(params[:topic])
	id = @subreddit.id
	@submission = Submission.find_by subreddit_id: id
	erb :single_submission
end

#not working
get '/r/:topic' do
	@subreddits = Subreddit.all
	@topic = params[:topic]
	@subreddit = Subreddit.find_by topic: params[:topic]
	# @submissions = Submission.find(:all, :subreddit_id => @subreddit.id)
	# @submissions.order("upvotes DESC")
	erb :subreddit_index
end

# having problems if topic is more than one word
post "/:topic/submission_new" do
	@subreddits = Subreddit.all
	if params[:link] != "" && params[:text] != ""
		redirect '/r/:topic/new'
	elsif params[:link] == "" && params[:text] == ""
		redirect '/r/:topic/new'
	else
		@topic = params[:topic]
		@subreddit = Subreddit.find_by topic: params[:topic]
		@id = @subreddit.id
		@submission = Submission.create(link: params[:link], text: params[:text], subreddit_id: @id)
	redirect "/r/#{params[:topic]}"
	end
end
 
 post "/subreddit_new" do
 	topic = params[:topic]
 	@subreddit = Subreddit.create(topic: topic)
 	redirect '/'
 end

post '/comment/:comment_id/upvotes' do
	# @comment_id = params[:comment_id]
	@upvoted_comment = Comment.find(params[:comment_id])
	@submission= Submission.find(@upvoted_comment.submission_id)
	@topic = Subreddit.find(@submission.subreddit_id)
	@topic = @topic.topic
	@upvoted_comment[:upvotes] += 1
	@upvoted_comment.save
	redirect "/r/#{@topic}/#{@submission.id}"
end

post '/comment/:comment_id/downvotes' do
	# @comment_id = params[:comment_id]
	@downvoted_comment = Comment.find(params[:comment_id])
	@submission= Submission.find(@downvoted_comment.submission_id)
	@topic = Subreddit.find(@submission.subreddit_id)
	@topic = @topic.topic
	@downvoted_comment[:downvotes] += 1
	@downvoted_comment.save
	redirect "/r/#{@topic}/#{@submission.id}"
end

post "/comment/:submission_id/new" do
	@submission_id = params[:submission_id]
 	@submission = Submission.find(params[:submission_id])
 	id = @submission.subreddit_id
 	@topic = Subreddit.find(id)
 	@topic = @topic.topic
 	@submission.comments.create(:body => params[:body])

 	redirect "/r/#{@topic}/#{@submission.id}"
 end

post "/comment/:comment_id/delete" do
	# @comment_id = params[:comment_id]
	@comment = Comment.find(params[:comment_id])
	@submission = Submission.find(@comment.submission_id)
	@topic = Subreddit.find(@submission.subreddit_id)
	@topic = @topic.topic
	@comment.delete

	redirect "/r/#{@topic}/#{@submission.id}"
end

post '/:topic/:submission_id/upvotes' do
	@topic = params[:topic]
	@subreddit = Subreddit.find_by topic: @topic
	@submission_id = params[:submission_id]
	upvoted = Submission.find(params[:submission_id])
	@topic = Subreddit.find(upvoted.subreddit_id)
	@topic = @topic.topic
	upvoted[:upvotes] += 1
	upvoted.save
	redirect "/r/#{@topic}"
end

post '/:topic/:submission_id/downvotes' do
	@topic = params[:topic]
	@subreddit = Subreddit.find_by topic: @topic
	@submission_id = params[:submission_id]
	downvoted = Submission.find(params[:submission_id])
	@topic = Subreddit.find(downvoted.subreddit_id)
	@topic = @topic.topic
	downvoted[:downvotes] += 1
	downvoted.save
	redirect "/r/#{@topic}"
end