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
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT
	)'
end

get '/' do
	erb :index
end

#обработчик get-запроса (браузер получает страницу с сервера)

get '/new' do
	erb :new
end

#обработчик post-запроса (браузер отправляет данные на сервер)

post '/new' do
	content = params[:content]

	#обработчик ошибки (пустое сообщение от пользователя)
	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	#добавление(сохранение данных) в таблицу Posts нового сообщения и дату его создания
	@db.execute 'insert into Posts (content, created_date) values (?, datetime())', [content]

	erb "You are typed #{content}"
end
