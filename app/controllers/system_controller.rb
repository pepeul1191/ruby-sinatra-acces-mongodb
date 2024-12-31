class SystemController < ApplicationController
  before do
    public_routes = ['/systems']
    unless public_routes.include?(request.path_info) 
      #check_session_true
    end
  end

  get '/systems' do
    message = params[:message] || nil
    status = params[:status] || nil
    locals = { 
      title: 'Gestión de Sistemas', 
      user: 'Usuario demo',
      error: false,
      status: status,
      message: message,
    }
    erb :'system/index', layout: :'layouts/application', locals: locals
  end

  get '/systems/add' do
    locals = { 
      title: 'Agregar Sistemas', 
      user: 'Usuario demo',
      subtile: 'Agregar Sistema',
      error: false
    }
    erb :'system/detail', layout: :'layouts/application', locals: locals
  end

  post '/systems/add' do
    begin
      name = params[:name]
      repo = params[:repo]
      system = System.create!(
        name: name,
        repo: repo,
        created_at: Time.now,
        updated_at: Time.now
      )
      redirect "/systems?status=success&message=Sistema creado, id: <b>#{system.id}</b>"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/systems?status=error&message=Ha ocurrido un error en guardar el sistema"
    end
  end
  
end