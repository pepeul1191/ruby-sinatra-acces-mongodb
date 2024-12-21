class LoginController < ApplicationController
  get '/login' do
    locals = { 
      title: "Bienvenido a la página de inicio de sesión", 
      user: "Usuario demo" 
    }
    erb :'login/index', layout: :'layouts/blank', locals: 
  end
end