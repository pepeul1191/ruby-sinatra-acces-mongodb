class SystemController < ApplicationController
  protected_routes = [
    '/systems',
  ]
  protected_routes.each do |path|
    before path do
      check_session_true
    end
  end

  get '/systems' do
    # request
    message = params[:message] || nil
    status = params[:status] || nil
    search_name = params[:name] || nil
    btn_search = params[:btn_search] || nil
    page = params[:page] || 1
    # blogic
    step = 10.0
    offset = (page.to_i - 1) * step.to_i
    if search_name and btn_search
      systems_count = System.where(name: /#{Regexp.escape(search_name)}/i).count
      systems = System.where(name: /#{Regexp.escape(search_name)}/i).skip(0).limit(step.to_i)
    elsif search_name and (not btn_search)
      systems_count = System.where(name: /#{Regexp.escape(search_name)}/i).count
      systems = System.where(name: /#{Regexp.escape(search_name)}/i).skip(offset).limit(step.to_i)
    else
      systems_count = System.count
      systems = System.skip(offset).limit(step.to_i)
    end
    #System.where(name: /^Sys|tem$/)
    # response
    locals = { 
      title: 'Gestión de Sistemas', 
      user: 'Usuario demo',
      error: false,
      status: status,
      message: message,
      systems: systems,
      search_name: search_name, 
      page: page.to_i, 
      total_pages: (systems_count / step).ceil
    }
    erb :'system/index', layout: :'layouts/application', locals: locals
  end

  get '/systems/create' do
    locals = { 
      title: 'Agregar Sistema', 
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

  get '/systems/:system_id/users' do
    # request
    system_id = params[:system_id]
    message = params[:message] || nil
    status = params[:status] || nil
    search_name = params[:name] || nil
    search_email = params[:email] || nil
    btn_search = params[:btn_search] || nil
    page = params[:page] || 1
    # blogic
    step = 10.0
    offset = (page.to_i - 1) * step.to_i
    if search_name and btn_search
      puts 'if +++++++++++++++++++++++'
      # user_count = User.count_roles(BSON::ObjectId(system_id), search_name)
      user_count = 20
      users = User.fetch_system_users(BSON::ObjectId(system_id), step, 0, search_name, search_email)
    elsif search_name and (not btn_search)
      # user_count = User.count_users(BSON::ObjectId(system_id), search_name)
      puts 'elefi +++++++++++++++++++++++'
      user_count = 20
      users = User.fetch_system_users(BSON::ObjectId(system_id), step, offset, search_name, search_email)
    else
      puts 'else +++++++++++++++++++++++'
      # user_count = User.count_users(BSON::ObjectId(system_id))
      user_count = 20
      users = User.fetch_system_users(BSON::ObjectId(system_id), step, offset)
    end
    puts '1 +++++++++++++++++++++++++++++++++++++'
    puts users
    puts '2 +++++++++++++++++++++++++++++++++++++'
    # response
    locals = { 
      title: 'Gestión de Usuarios del Sistema', 
      user: 'Usuario demo',
      error: false,
      status: status,
      message: message,
      users: users,
      search_name: search_name, 
      search_email: search_email, 
      page: page.to_i, 
      system_id: system_id, 
      total_pages: (user_count / step).ceil
    }
    erb :'system/users', layout: :'layouts/application', locals: locals
  end
end