require 'sinatra/base'

class ApplicationController < Sinatra::Base
  # Establece el directorio de las vistas
  set :views, File.expand_path('../../views', __FILE__)
  # Establece la carpeta de archivos estáticos
  set :public_folder, File.expand_path('../../../public', __FILE__)
  # Habilitar logging
  configure :development, :production do
    enable :logging
  end

  # Antes de cada petición, configura el logger
  before do
    env["rack.logger"] = Logger.new(STDOUT)
  end

  get '/' do
    puts 'base'
    erb :'home/index'
  end
end
