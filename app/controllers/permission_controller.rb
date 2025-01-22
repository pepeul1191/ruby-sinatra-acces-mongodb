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

  post '/systems/:system_id/roles/:role_id/permissions' do
    begin
      role_id = params[:role_id]
      system_id = params[:system_id]
      name = params[:name]
      description = params[:description]
      permission = Permission.create!(
        name: name,
        description: description,
        created: Time.now,
        updated: Time.now,
      )
      role = Role.find(BSON::ObjectId(role_id))
      role.push(permission_ids: permission.id)
      redirect "/systems/#{system_id}/roles/edit/#{role.id}?status=success&message=Rol creado, id: <b>#{role.id}</b>"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/systems/#{system_id}/roles?status=error&message=Ha ocurrido un error en guardar el rol del sistema"
    end
  end
end