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
      users_count = User.where(
        "$or" => [
          { name: /#{Regexp.escape(search_name)}/i },
          { email: /#{Regexp.escape(search_email)}/i }
        ]
      ).count
      users = User.where(
        "$or" => [
          { name: /#{Regexp.escape(search_name)}/i },
          { email: /#{Regexp.escape(search_email)}/i }
        ]
      ).skip(0).limit(step.to_i)
    elsif (search_name && !search_name.empty?) || (search_email && !search_email.empty?) and (not btn_search)
      users_count = User.where(
        "$or" => [
          { name: /#{Regexp.escape(search_name)}/i },
          { email: /#{Regexp.escape(search_email)}/i }
        ]
      ).count
      users = User.where(
        "$or" => [
          { name: /#{Regexp.escape(search_name)}/i },
          { email: /#{Regexp.escape(search_email)}/i }
        ]
      ).skip(offset).limit(step.to_i)
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
    locals = { 
      title: 'Agregar Usuario', 
      logged_user: 'Usuario demo',
      subtile: 'Agregar Usuario',
      user: nil,
      error: false
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
        redirect "/users?status=success&message=Usuario creado, id: <b>#{user.id}</b>, se ha enviado un correo de activación a <b>#{email}</b>"
      end
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/users?status=error&message=Ha ocurrido un error en guardar el usuario"
    end
  end
end