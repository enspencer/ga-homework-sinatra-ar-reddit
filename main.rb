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

get '/r/:topic/newest' do
	@subreddits = Subreddit.all
	topic = params[:topic]
	@subreddit = Subreddit.find_by topic: params[:topic]
	@subreddit.order("upvotes DESC")
	erb :subreddit_by_newest
end

# having trouble with this
get '/r/:topic/:submission_id' do
	@subreddits = Subreddit.all
	@topic = params[:topic]
	@submission_id = params[:submission_id]
	@subreddit = Subreddit.find_by topic: params[:topic]
	id = @subreddit.id
	@submission = Submission.find_by subreddit_id: id
	erb :single_submission
end

get '/r/:topic' do
	@subreddits = Subreddit.all
	topic = params[:topic]
	@subreddit = Subreddit.find_by topic: params[:topic]
	erb :subreddit_index
end

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

 post "/comment/:submission_id/new" do
 	@submission = Submission.find(params[:submission_id])
 	@submission.comments.create(body: body)
 	topic = Subreddit.find(params[:@submission.subreddit_id])

 	redirect "/r/#{topic}"
 end


post '/:topic/:submission_id/upvotes' do
	@topic = params[:topic]
	@subreddit = Subreddit.find_by topic: @topic
	@submission_id = params[:submission_id]
	upvoted = Submission.find(params[:submission_id])
	upvoted[:upvotes] += 1
	upvoted.save
	redirect "/r/#{@subreddit.topic}"
end

post '/:topic/:submission_id/downvotes' do
	@topic = params[:topic]
	@subreddit = Subreddit.find_by topic: @topic
	@submission_id = params[:submission_id]
	downvoted = Submission.find(params[:submission_id])
	downvoted[:downvotes] += 1
	downvoted.save
	redirect "/r/#{@subreddit.topic}"
end

post '/comment/:submission_id/upvotes' do
	@submission_id = params[:submission_id]
	@submission = Submission.find(params[:submission_id])
	topic = Subreddit.find(@submission.subreddit_id)
	upvoted = Comment.find(params[:submission_id])
	upvoted[:upvotes] += 1
	upvoted.save
	redirect "/r/:topic/:submission_id"
end

post '/comment/:submission_id/downvotes' do
	@submission_id = params[:submission_id]
	@submission = Submission.find(params[:submission_id])
	@topic = Subreddit.find(@submission.subreddit_id)
	downvoted = Comment.find(params[:submission_id])
	downvoted[:downvotes] += 1
	downvoted.save
	redirect "/r/:topic/:submission_id"
end