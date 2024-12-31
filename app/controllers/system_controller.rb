class SystemController < ApplicationController
  before do
    public_routes = ['/systems']
    unless public_routes.include?(request.path_info) 
      #check_session_true
    end
  end

  get '/systems' do
    locals = { 
      title: 'Gestión de Sistemas', 
      user: 'Usuario demo',
      error: false
    }
    erb :'system/index', layout: :'layouts/application', locals: locals
  end
end