require 'sinatra/base'
require "sinatra/reloader"
require 'sass'
require 'sass/plugin/rack'
require 'redis'
require 'json'

class App < Sinatra::Application
  use Sass::Plugin::Rack

  set :views, File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'

  get '/hello' do
    @count=count

    status 200
    erb :index
  end

  put '/update' do
    content_type :json
    action = JSON.parse(request.body.read)["action"]
    
    case action
    when "increment" 
      redis.incr "count"
    when "decrement"
      redis.decr "count"
    when "reset"
      redis.set "count", 0
    end

    status 200
    { count: count }.to_json
  end

  private

  def redis
    @redis ||= Redis.new
  end 

  def count
    redis.get("count")
  end
end