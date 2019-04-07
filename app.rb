#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sqlite3'

def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

before do
	init_db
end

configure do
	init_db
	@db.execute 'CREATE TABLE IF NOT EXISTS Posts
	(
	Id INTEGER PRIMARY KEY AUTOINCREMENT,
	youname TEXT, 
	created_date DATE, 
	content TEXT
	)'

	 @db.execute 'CREATE TABLE IF NOT EXISTS Comments
	 (
	 Id INTEGER PRIMARY KEY AUTOINCREMENT,
	 youname TEXT,
	 created_date DATE,
	 content TEXT,
	 post_id INTEGER
	 )'
end


get '/' do

	@results = @db.execute 'select * from Posts order by id desc'
	erb :index
end

get '/new' do
  erb :new
end

post '/new' do
	content = params[:content]
	youname = params[:youname]
	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	if youname.length <= 0
		@error = 'Type you name'
		return erb :new
	end

	@db.execute 'insert into Posts (youname, content, created_date) values (?,?,datetime())',[youname, content]
	redirect to '/'
	#erb "You typed: #{youname}, #{content}"
end

get '/details/:post_id' do
	post_id = params[:post_id]

	results = @db.execute 'select * from Posts where Id = ?', [post_id]
	@row = results[0]

	@comments = @db.execute 'select * from Comments where post_id = ? order by Id', [post_id]
	erb :details
end

post '/details/:post_id' do
	post_id = params[:post_id]
	content = params[:content]

	@db.execute 'insert into Comments 
	(
		content,
		created_date, 
		post_id
	) 
		values 
	(
		?, 
		datetime(),
		?
	)', [content, post_id]	
	
	redirect to('/details/' + post_id)
end

