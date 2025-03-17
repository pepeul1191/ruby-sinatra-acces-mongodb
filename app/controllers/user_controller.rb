class UserController < ApplicationController
  include UserHelper

  protected_routes = [
    '/users',
  ]
  protected_routes.each do |path|
    before path do
      check_session_true
    end
  end

  get '/users' do
    # request
    message = params[:message] || nil
    status = params[:status] || nil
    search_name = params[:name] || nil
    search_email = params[:email] || nil
    btn_search = params[:btn_search] || nil
    page = params[:page] || 1
    # blogic
    step = 10.0
    offset = (page.to_i - 1) * step.to_i
    if (search_name && !search_name.empty?) || (search_email && !search_email.empty?) and btn_search
      query = {}
      query["$and"] = []
      query["$and"] << { name: /#{Regexp.escape(search_name)}/i } if search_name && !search_name.empty?
      query["$and"] << { email: /#{Regexp.escape(search_email)}/i } if search_email && !search_email.empty?
      if query["$and"].any?
        users_count = User.where(query).count
        users = User.where(query).skip(offset).limit(step.to_i)
      else
        # Si no hay búsqueda, puedes devolver todos los usuarios o algo por defecto
        users_count = User.count
        users = User.skip(offset).limit(step.to_i)
      end
    elsif (search_name && !search_name.empty?) || (search_email && !search_email.empty?) and (not btn_search)
      query = {}
      query["$and"] = []
      query["$and"] << { name: /#{Regexp.escape(search_name)}/i } if search_name && !search_name.empty?
      query["$and"] << { email: /#{Regexp.escape(search_email)}/i } if search_email && !search_email.empty?
      if query["$and"].any?
        users_count = User.where(query).count
        users = User.where(query).skip(offset).limit(step.to_i)
      else
        # Si no hay búsqueda, puedes devolver todos los usuarios o algo por defecto
        users_count = User.count
        users = User.skip(offset).limit(step.to_i)
      end
    else
      users_count = User.count
      users = User.skip(offset).limit(step.to_i)
    end
    #User.where(name: /^Sys|tem$/)
    # response
    locals = { 
      title: 'Gestión de Usuarios', 
      user: 'Usuario demo',
      error: false,
      status: status,
      message: message,
      users: users,
      search_name: search_name,
      search_email: search_email, 
      page: page.to_i, 
      total_pages: (users_count / step).ceil
    }
    erb :'user/index', layout: :'layouts/application', locals: locals
  end

  get '/users/create' do
    status = params[:status] || nil
    locals = { 
      title: 'Agregar Usuario', 
      logged_user: 'Usuario demo',
      subtile: 'Agregar Usuario',
      user: nil,
      error: false,
      status: status
    }
    erb :'user/detail', layout: :'layouts/application', locals: locals
  end

  post '/users' do
    begin
      name = params[:name]
      email = params[:email]
      password = params[:password]
      user_repeted = User.where(
        "$or" => [
          { name: name },
          { email: email }
        ]
      ).count
      if user_repeted != 0
        redirect "/users?status=error&message=Usuario o correo en uso, no se ha podido crear el nuevo usuario."
      else
        user = User.create!(
          name: name,
          password: encrypt(password),
          email: email,
          created: Time.now,
          updated: Time.now, 
          activation_key: random_key(20),
          reset_key: random_key(20),
          activated: false,
        )
        send_activation_email(email, activation_key)
        redirect "/users?status=success&message=Usuario creado, id: <b>#{user.id}</b>, se ha enviado un correo de activación a <b>#{email}</b>"
      end
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/users?status=error&message=Ha ocurrido un error en guardar el usuario"
    end
  end

  get '/users/edit/:_id' do
    begin
      _id = params[:_id]
      status = params[:status] || nil
      message = params[:message] || nil
      user = User.find(_id)
      locals = { 
        title: 'Editar Usuario', 
        user: 'Usuario demo',
        subtile: 'Editar Usuario',
        error: false,
        logged_user: 'Usuario demo',
        user: user,
        status: status,
        message: message,
      }
      erb :'user/detail', layout: :'layouts/application', locals: locals
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/users?status=error&message=Ha ocurrido un error en editar el usuario"
    end
  end

  get '/users/:_id/reset-activation' do
    begin
      user = User.find(params[:_id])
      updated_fields = {} 
      key = random_key(20)
      updated_fields[:activation_key] = key
      updated_fields[:updated] = Time.now
      user.update!(updated_fields)
      send_activation_email(user.email, key)
      redirect "users/edit/#{params[:_id]}?status=success&message=Se ha enviado un correo de activación del usuario"
    rescue Mongoid::Errors::DocumentNotFound
      redirect "users/?status=error&message=No se encontró el usuario con el ID especificado"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "users/edit/#{params[:_id]}?status=error&message=Ocurrió un error al actualizar la activación del usuario."
    end
  end


  get '/users/:_id/activated' do
    begin
      user = User.find(params[:_id])
      updated_fields = {} 
      updated_fields[:activated] = (params[:value] == 'true'? true : false) 
      user.update!(updated_fields)
      redirect "users/edit/#{params[:_id]}?status=success&message=Se cambio el estado de de activación del usuario"
    rescue Mongoid::Errors::DocumentNotFound
      redirect "users/?status=error&message=No se encontró el usuario con el ID especificado"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "users/edit/#{params[:_id]}?status=error&message=Ocurrió un error al actualizar la activación del usuario."
    end
  end

  get '/users/:_id/reset-password' do
    begin
      user = User.find(params[:_id])
      updated_fields = {} 
      key = random_key(20)
      updated_fields[:reset_key] = key
      updated_fields[:updated] = Time.now
      user.update!(updated_fields)
      send_reset_email(user.email, key)
      redirect "users/edit/#{params[:_id]}?status=success&message=Se ha enviado un correo de cambio de contraseña del usuario"
    rescue Mongoid::Errors::DocumentNotFound
      redirect "users/?status=error&message=No se encontró el usuario con el ID especificado"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "users/edit/#{params[:_id]}?status=error&message=Ocurrió un error al actualizar la activación del usuario."
    end
  end

  post '/users/:_id' do
    begin
      user = User.find(params[:_id])
      updated_fields = {}
      # check name is being updated and if it already exists for another user
      if params[:name] && params[:name] != user.name
        if User.where(name: params[:name]).exists?
          redirect "/users/edit/#{params[:_id]}?status=error&message=El nombre de usuario ya está en uso"
          return
        end
        updated_fields[:name] = params[:name]
      end
      # check email is being updated and if it already exists for another user
      if params[:email] && params[:email] != user.email
        if User.where(email: params[:email]).exists?
          redirect "/users/edit/#{params[:_id]}?status=error&message=El correo electrónico ya está en uso"
          return
        end
        updated_fields[:email] = params[:email]
      end
      # check new password
      if params[:password] && params[:password] != user.email
        updated_fields[:password] = params[:password]
      end
      # update
      updated_fields[:updated] = Time.now
      user.update!(updated_fields)  # Actualiza al usuario con los nuevos campos
      redirect "/users/edit/#{params[:_id]}?status=success&message=Usuario actualizado correctamente"
    rescue Mongoid::Errors::DocumentNotFound
      redirect "/users/?status=error&message=No se encontró el usuario con el ID especificado"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/users/edit/#{params[:_id]}?status=error&message=Ocurrió un error al actualizar el usuario"
    end
  end  
end