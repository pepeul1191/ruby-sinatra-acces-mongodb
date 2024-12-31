class SystemController < ApplicationController
  before do
    public_routes = ['/systems']
    unless public_routes.include?(request.path_info) 
      #check_session_true
    end
  end

  get '/systems' do
    systems = System.all
    message = params[:message] || nil
    status = params[:status] || nil
    locals = { 
      title: 'Gestión de Sistemas', 
      user: 'Usuario demo',
      error: false,
      status: status,
      message: message,
      systems: systems,
    }
    erb :'system/index', layout: :'layouts/application', locals: locals
  end

  get '/systems/create' do
    locals = { 
      title: 'Agregar Sistemas', 
      user: 'Usuario demo',
      subtile: 'Agregar Sistema',
      system: nil,
      error: false
    }
    erb :'system/detail', layout: :'layouts/application', locals: locals
  end

  post '/systems' do
    begin
      name = params[:name]
      repo = params[:repo]
      system = System.create!(
        name: name,
        repo: repo,
        created: Time.now,
        updated: Time.now
      )
      redirect "/systems?status=success&message=Sistema creado, id: <b>#{system.id}</b>"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/systems?status=error&message=Ha ocurrido un error en guardar el sistema"
    end
  end

  get '/systems/delete/:_id' do
    begin
      _id = params[:_id]
      system = System.find(_id)
      system.destroy  
      redirect "/systems?status=success&message=Sistema eliminado</b>"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/systems?status=error&message=Ha ocurrido un error en editar el sistema"
    end
  end

  get '/systems/edit/:_id' do
    begin
      _id = params[:_id]
      system = System.find(_id)
      locals = { 
        title: 'Editar Sistema', 
        user: 'Usuario demo',
        subtile: 'Editar Sistema',
        error: false,
        system: system,
      }
      erb :'system/detail', layout: :'layouts/application', locals: locals
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/systems?status=error&message=Ha ocurrido un error en editar el sistema"
    end
  end

  post '/systems/:_id' do
    begin
      system = System.find(params[:_id])
      updated_fields = {}
      updated_fields[:name] = params[:name] if params[:name]
      updated_fields[:repo] = params[:repo] if params[:repo]
      updated_fields[:updated] = Time.now
      system.update!(updated_fields)
      redirect "/systems?status=success&message=Sistema actualizado correctamente"
    rescue Mongoid::Errors::DocumentNotFound
      redirect "/systems?status=error&message=No se encontró el sistema con el ID especificado"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/systems?status=error&message=Ocurrió un error al actualizar el sistema"
    end
  end
end