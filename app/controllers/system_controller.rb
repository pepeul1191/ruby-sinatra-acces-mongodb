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
    registered = params[:registered] == 'true' ? true : params[:registered] == 'false' ? false : nil
    page = params[:page] || 1
    # blogic
    step = 10.0
    offset = (page.to_i - 1) * step.to_i
    if (search_name or search_email or registered != nil) and btn_search
      user_count = User.count_system_users(BSON::ObjectId(system_id), search_name, search_email, registered)
      users = User.fetch_system_users(BSON::ObjectId(system_id), step, 0, search_name, search_email, registered)
    elsif (search_name or search_email or (registered != nil)) and (not btn_search)
      user_count = User.count_system_users(BSON::ObjectId(system_id), search_name, search_email, registered)
      users = User.fetch_system_users(BSON::ObjectId(system_id), step, offset, search_name, search_email, registered)
    else
      user_count = User.count_system_users(BSON::ObjectId(system_id))
      users = User.fetch_system_users(BSON::ObjectId(system_id), step, offset)
    end
    # href add/remove parameteres
    parameters = []
    parameters << "btn_search=#{btn_search}" if btn_search && !btn_search.to_s.empty?
    parameters << "name=#{search_name}" if search_name && !search_name.to_s.empty?
    parameters << "email=#{search_email}" if search_email && !search_email.to_s.empty?
    parameters << "registered=#{registered}" if [true, false].include?(registered)
    parameters << "page=#{page}" if page && page.to_i > 1 # Solo agrega si `page` es mayor a 1
    query_string = parameters.any? ? "?#{parameters.join('&')}" : ""
    # puts query_string
    # response
    locals = { 
      title: 'Gestión de Usuarios del Sistema', 
      user: 'Usuario demo',
      error: false,
      status: status,
      message: message,
      users: users, # array(hash)
      search_name: search_name, 
      search_email: search_email, 
      registered: registered,
      page: page.to_i, 
      system_id: system_id, 
      total_pages: (user_count / step).ceil,
      parameters: query_string
    }
    erb :'system/users', layout: :'layouts/application', locals: locals
  end

  get '/systems/:system_id/users/:user_id/add' do
    begin
      system_id = params[:system_id]
      user_id = params[:user_id]
      search_name = params[:name] || nil
      search_email = params[:email] || nil
      btn_search = params[:btn_search] || nil
      registered = params[:registered] == 'true' ? true : params[:registered] == 'false' ? false : nil
      page = params[:page] || 1
      puts 'endpoint'
      puts registered
      # blogic
      system = System.find(BSON::ObjectId(system_id))
      system.push(user_ids: BSON::ObjectId(user_id))
      # href add/remove parameteres
      parameters = []
      parameters << "btn_search=#{btn_search}" if btn_search && !btn_search.to_s.empty?
      parameters << "name=#{search_name}" if search_name && !search_name.to_s.empty?
      parameters << "email=#{search_email}" if search_email && !search_email.to_s.empty?
      parameters << "registered=#{registered}" if [true, false].include?(registered)
      parameters << "page=#{page}" if page && page.to_i > 1 # Solo agrega si `page` es mayor a 1
      query_string = parameters.any? ? "#{parameters.join('&')}" : ""
      puts query_string
      # response
      redirect "/systems/#{system_id}/users?status=success&message=Se ha agregado el usuario al sistema&#{query_string}"
    rescue Mongoid::Errors::DocumentNotFound
      redirect "/systems/#{system_id}/users?status=error&message=No se encontró el sistema con el ID especificado&#{query_string}"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/systems/#{system_id}/users?status=error&message=Ocurrió un error al agregar el usuario al sistema"
    end
  end

  get '/systems/:system_id/users/:user_id/remove' do
    begin
      system_id = params[:system_id]
      user_id = params[:user_id]
      search_name = params[:name] || nil
      search_email = params[:email] || nil
      btn_search = params[:btn_search] || nil
      registered = params[:registered] == 'true' ? true : params[:registered] == 'false' ? false : nil
      # http://localhost:9292/systems/67885aad2d163a785ef1ade8/users?status=success&message=Se%20ha%20retirado%20el%20usuario%20al%20sistema&btn_search=1&registered=true
      page = params[:page] || 1
      # blogic
      system = System.find(BSON::ObjectId(system_id))
      system.pull(user_ids: BSON::ObjectId(user_id))
      # href add/remove parameteres
      parameters = []
      parameters << "btn_search=#{btn_search}" if btn_search && !btn_search.to_s.empty?
      parameters << "name=#{search_name}" if search_name && !search_name.to_s.empty?
      parameters << "email=#{search_email}" if search_email && !search_email.to_s.empty?
      parameters << "registered=#{registered}" if [true, false].include?(registered)
      parameters << "page=#{page}" if page && page.to_i > 1 # Solo agrega si `page` es mayor a 1
      query_string = parameters.any? ? "#{parameters.join('&')}" : ""
      # response
      redirect "/systems/#{system_id}/users?status=success&message=Se ha retirado el usuario al sistema&#{query_string}"
    rescue Mongoid::Errors::DocumentNotFound
      redirect "/systems/#{system_id}/users?status=error&message=No se encontró el sistema con el ID especificado&#{query_string}"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/systems/#{system_id}/users?status=error&message=Ocurrió un error al agregar el usuario al sistema"
    end
  end
end