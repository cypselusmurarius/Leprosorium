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
		username TEXT,
		content TEXT
	)'

	@db.execute 'CREATE TABLE IF NOT EXISTS Comments
	(
		id INTEGER PRIMARY KEY AUTOINCREMENT,
		created_date DATE,
		content TEXT,
		post_id integer
	)'
end

get '/' do

	# выбираем список постов из базы данных
	@results = @db.execute 'select * from Posts order by id desc'

	erb :index
end

# обработчик get-запроса (браузер получает страницу с сервера)
get '/new' do
	erb :new
end

# обработчик post-запроса (браузер отправляет данные на сервер)
post '/new' do

	# получаем переменные из post-запроса
	content = params[:content]
	name = params[:username]

	# обработчик ошибки (пустое сообщение от пользователя)
	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	# добавление(сохранение данных) в таблицу Posts нового сообщения и дату его создания
	@db.execute 'insert into Posts (content, created_date, username) values (?, datetime(), ?)', [content, name]

	# перенаправление на главную страницу
	redirect to '/'
end

# вывод информации о посте

get '/details/:post_id' do

	# получаем переменную из url`а
	post_id = params[:post_id]

	# получаем список постов
	# (у нас будет только один пост)
	results = @db.execute 'select * from Posts where id = ?', [post_id]

	# выбираем этот один пост в переменную @row
	@row = results[0]

	# выбираем комментарии для нашего поста
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	# возвращаем представление details.erb
	erb :details
end

# обработчик post-запроса /details/...
# (браузер отправляет данные на сервер, мы их принимаем)

post '/details/:post_id' do

	# получаем переменную из url`а
	post_id = params[:post_id]

	# получаем переменную из post-запроса
	content = params[:content]

	if content.length <= 0
		@error = 'Type comment text'
		return redirect to ('/details/'+ post_id)
	end

	#сохранение данных в БД
	@db.execute 'insert into Comments (content, created_date, post_id) values (?, datetime(), ?)', [content, post_id]

	redirect to ('/details/'+ post_id)
end
