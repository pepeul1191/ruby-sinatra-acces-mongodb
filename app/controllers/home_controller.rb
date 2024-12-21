class HomeController < ApplicationController
  get '/home' do
    puts 'homeeeeeeeeee'
    erb :'home/index'
  end
end