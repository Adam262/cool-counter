require 'sinatra/base'
require "sinatra/reloader"
require 'sass'
require 'sass/plugin/rack'
# require 'redis'

class App < Sinatra::Application
  use Sass::Plugin::Rack

  set :views, File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'

  get '/hello' do
    status 200

    erb :index
  end

  private

  # def redis
  #   @redis ||= Redis.new
  # end 
end
