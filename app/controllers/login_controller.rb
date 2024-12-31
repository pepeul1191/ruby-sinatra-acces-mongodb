class LoginController < ApplicationController

  [
    '/login',
  ].each do |path|
    before path do
      if_session_true_go_home
    end
  end

  get '/login' do
    locals = { 
      title: 'Bienvenido a la página de inicio de sesión', 
      user: 'Usuario demo',
      error: false
    }
    erb :'login/index', layout: :'layouts/blank', locals: locals
  end

  post '/login' do
    username = params[:username] # Capturar el nombre de usuario
    password = params[:password] # Capturar la contraseña
    # Validación básica (sustituir con la lógica de autenticación real)
    if username == 'admin' && password == 'sistema123'
      session[:logged] = true
      redirect '/'  # Redirige a una página de éxito
    else
      error = 'Usuario o contraseña incorrectos'
      locals = { 
        title: 'Bienvenido a la página de inicio de sesión', 
        user: 'Usuario demo',
        error: error
      }
      erb :'login/index', layout: :'layouts/blank',  locals: locals
    end
  end
end