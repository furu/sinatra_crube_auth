require 'bundler/setup'

require 'sinatra'
require 'sinatra/activerecord'
require 'slim'
require 'rack-flash'
require 'sinatra/cookies'

require_relative 'models/user'

module SessionsHelper
  def sign_in(user)
    remember_token = User.new_remember_token
    cookies[:remember_token] = remember_token
    user.update_attribute(:remember_token, User.encrypt(remember_token))
    self.current_user = user
  end

  def signed_in?
    !current_user.nil?
  end

  def sign_out
    self.current_user = nil
    cookies.delete(:remember_token)
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    remember_token = User.encrypt(cookies[:remember_token])
    @current_user ||= User.find_by(remember_token: remember_token)
  end

  def current_user?(user)
    user == current_user
  end
end

configure :development do
  require 'sinatra/reloader'
  require 'pry'
end

configure do
  enable :sessions
end

use Rack::Flash
helpers SessionsHelper

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
    flash[:error] = 'Invalid email/password combination'
    redirect back
  end
end

# セッションを削除する (サインアウト)
delete '/sighout' do
  sign_out
  redirect '/'
end

__END__
