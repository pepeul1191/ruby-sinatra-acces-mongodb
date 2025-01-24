class UserController < ApplicationController
  get '/users' do
    locals = { 
      title: 'Gestión de Usuarios', 
      error: false,
      status: nil,
      message: 'message',
      users: [],
      search_name: 'search_name', 
      #page: page.to_i, 
      #total_pages: (systems_count / step).ceil
    }
    erb :'user/index', layout: :'layouts/application', locals: locals
  end
end