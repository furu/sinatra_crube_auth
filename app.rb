require 'bundler/setup'

require 'sinatra'
require 'sinatra/activerecord'
require 'slim'

require_relative 'models/user'

configure :development do
  require 'sinatra/reloader'
  require 'pry'
end


get '/' do
  'hi'
end

__END__
