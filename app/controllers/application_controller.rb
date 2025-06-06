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
    set :constants, CONSTANTS[:local]
  end

  before do
    env["rack.logger"] = Logger.new(STDOUT)
  end

  helpers Helpers

  [
    '/', '/sign-out',  
  ].each do |path|
    before path do
      check_session_true
    end
  end

  not_found do
    # Lista de extensiones de archivos estáticos que no deben devolver un 404 con un ERB
    extensions = ['css', 'js', 'png', 'jpg', 'gif', 'svg', 'ico', 'woff', 'woff2', 'ttf', 'eot', 'mp4', 'webm']
    # Obtener la extensión del archivo de la URL
    ext = File.extname(request.path).delete_prefix('.')
    # Si la extensión no está en la lista, renderiza la página 404
    unless extensions.include?(ext)
      status 404
      locals = { 
        title: 'Recurso no encontrado', 
      }
      erb :'application/not_found', layout: :'layouts/blank', locals: locals
    end
  end

  get '/' do
    locals = { 
      title: 'Gestión de Accesos', 
    }
    erb :'application/home', layout: :'layouts/application', locals: locals
  end

  get '/sign-out' do
    session.clear
    redirect '/login'
  end
end
