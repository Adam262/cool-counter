require 'sinatra/base'
require "sinatra/reloader"
require 'sass'
require 'sass/plugin/rack'
require 'redis'
require 'json'
require 'thin'

class App < Sinatra::Application
  use Sass::Plugin::Rack

  set :views, File.dirname(__FILE__) + '/views'
  set :public_folder, File.dirname(__FILE__) + '/public'

  set :bind, '0.0.0.0'

  get '/' do
    @count=count

    status 200
    erb :index
  end

  get '/ping' do
    status 200
    'pong'
  end

  put '/update' do
    content_type :json
    action = JSON.parse(request.body.read)["action"]
    
    case action
    when "plus" 
      redis.incr("count")
    when "minus"
      redis.decr("count") if count.to_i > 0
    when "reset"
      redis.set("count", 0)
    end

    status 200
    { count: count }.to_json
  end

  private

  def count
    redis.get("count") || 0
  end
  
  def redis
    @redis ||= Redis.new(host: redis_host, port: 6379)
  end 

  def redis_host
    ENV.fetch('REDIS_HOST', '127.0.0.1')
  end
end
