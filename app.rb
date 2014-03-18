require 'bundler/setup'

require 'sinatra'
require 'sinatra/activerecord'
require 'slim'

require_relative 'models/user'

configure :development do
  require 'sinatra/reloader'
  require 'pry'
end

configure do
  enable :sessions
end


get '/' do
  slim :index
end

# 新しいセッション用 (サインイン)
get '/signin' do
  slim :signin
end

# 新しいセッションを作成する
post '/sessions' do
  user = User.find_by(email: params[:session][:email].downcase)
  if user && user.authenticate(params[:session][:password])
    sign_in user
    redirect '/'
  else
    slim :signin
  end
end

# セッションを削除する (サインアウト)
delete '/sighout' do
end

__END__
