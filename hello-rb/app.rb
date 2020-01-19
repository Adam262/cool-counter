require 'sinatra'
require "sinatra/reloader" if development?
require 'sass'
require 'sass/plugin/rack'
use Sass::Plugin::Rack

get '/hello' do
  status 200

  erb :index
end
