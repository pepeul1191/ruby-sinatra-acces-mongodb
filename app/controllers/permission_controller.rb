class PermissionController < ApplicationController
  before do
    public_routes = []
    unless public_routes.include?(request.path_info) 
      #check_session_true
    end
  end
  get '/systems/:system_id/roles/:role_id/permissions/create' do
    locals = { 
      title: 'Agregar Permiso a Rol', 
      user: 'Usuario demo',
      subtile: 'Agregar Permiso a Rol',
      system_id: params[:system_id], 
      role_id: params[:role_id],
      error: false,
      page: nil,
      permission: nil 
    }
    erb :'permission/detail', layout: :'layouts/application', locals: locals
  end
end