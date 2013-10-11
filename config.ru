require 'rubygems'

require 'sinatra/base'
require './lib/models'


class Subscriber < Sinatra::Base

  post '/' do

    subscription = Subscription.new(:email => params[:email])
    if subscription.save
      redirect '/thank_you'
    else
      redirect '/'
    end
  end
end


class DirectoryIndex
  def initialize(app)
    @app = app
  end

  def call(env)
    if File.directory?(File.join(File.dirname(__FILE__), 'build', env['PATH_INFO']))
      env['PATH_INFO'].gsub!(/\/?$/,'/')
    end
    @app.call(env)
  end
end


class NotFound
  def initialize(path = '')
    @path = path
    @content = 'Not Found'
  end
  
  def call(env)
    if ::File.exist?(@path)
      @content = ::File.read(@path)
    end
    length = @content.length.to_s
    [404, {'Content-Type' => 'text/html', 'Content-Length' => length}, [@content]]
  end
end

class StaticSite
  def initialize(root='build')
    @app = Rack::Builder.new do
      use DirectoryIndex
      use Rack::Static,
        :urls => Dir.glob("#{root}/*").map { |fn| fn.gsub(/#{root}/, '')},
        :root => root,
        :index => 'index.html',
        :header_rules => [[:all, {'Cache-Control' => 'public, max-age=3600'}]]

      run NotFound.new("#{root}/404/index.html")
    end
  end

  def call(env)
    @app.call(env)
  end

end

app = Rack::Builder.app do
  map "/subscribe" do
    run Subscriber
  end
  map "/" do
    run StaticSite.new
  end
end

run app
