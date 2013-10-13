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
	erb :reddit_by_newest
end

get '/r/:topic/new' do
	@topic = params[:topic]
	erb :submission_new
end

get '/r/:topic/newest' do
	topic = params[:topic]
	erb :subreddit_by_newest
end

# having trouble with this
get '/r/:topic/:submission_id' do
	@topic = params[:topic]
	@submission_id = params[:submission_id]
	@subreddit = Subreddit.find_by topic: params[:topic]
	id = @subreddit.id
	@submission = Submission.find_by subreddit_id: id
	erb :single_submission
end

get '/r/:topic' do
	topic = params[:topic]
	@subreddit = Subreddit.find_by topic: params[:topic]
	erb :subreddit_index
end

# having trouble
post "/:topic/submission_new" do
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