require 'sinatra/base'

class ApplicationController < Sinatra::Base
  # Habilitar logging
  configure :development, :production do
    enable :logging
  end

  enable :sessions # Habilitar sesiones

  configure do
    set :session_secret, 'a4b89e6d2f4c7b98334f5e2c1e93460b2f94b24a6c9e5d073c44d4e69e839485'
    set :sessions, expire_after: 3600
    set :views, File.expand_path('../../views', __FILE__)
    set :public_folder, File.expand_path('../../../public', __FILE__)
  end

  before do
    env["rack.logger"] = Logger.new(STDOUT)
  end

  before do
    public_routes = ['/login', '/signup']
    unless public_routes.include?(request.path_info) || session[:logged]
      redirect '/login'
    end
  end

  not_found do
    extensions = ['css', 'js', 'png', ]
    path = request.path.split('.')
    if !extensions.include? path[path.length - 1]
      status 404
      '404: Recurso no encontrado'
    end
  end

  get '/' do
    erb :'home/index', layout: :'layouts/application'
  end

  get '/sign-out' do
    session.clear
    redirect '/login'
  end
end
