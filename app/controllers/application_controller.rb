require 'sinatra/base'

class ApplicationController < Sinatra::Base
  # Establece el directorio de las vistas
  set :views, File.expand_path('../../views', __FILE__)
  # Establece la carpeta de archivos estáticos
  set :public_folder, File.expand_path('../../../public', __FILE__)

  get '/' do
    erb :index
  end
end
