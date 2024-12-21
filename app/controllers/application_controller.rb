require 'sinatra/base'

class ApplicationController < Sinatra::Base
  set :views, File.expand_path('../../views', __FILE__)

  get '/' do
    puts '++++++++++++++++++++++++'
    erb :index
  end
end