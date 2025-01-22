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

  get '/systems/:system_id/roles/:role_id/permissions/edit/:permission_id' do
    begin
      message = params[:message] || nil
      _id = params[:permission_id]
      permission = Permission.find(_id)
      message = params[:message] || nil
      locals = { 
        title: 'Editar Permiso', 
        user: 'Usuario demo',
        subtile: 'Editar Permiso',
        error: false,
        system_id: params[:system_id], 
        role_id: params[:role_id],
        permission: permission,
        permission_id: _id,
        message: message, 
      }
      erb :'permission/detail', layout: :'layouts/application', locals: locals
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/permissions?status=error&message=Ha ocurrido un error en editar el sistema"
    end
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

  post '/systems/:system_id/roles/:role_id/permissions/:_id' do
    begin
      system_id = params[:system_id]
      role_id = params[:role_id]
      permission = Permission.find(params[:_id])
      updated_fields = {}
      updated_fields[:name] = params[:name] if params[:name]
      updated_fields[:description] = params[:description] if params[:description]
      updated_fields[:updated] = Time.now
      permission.update!(updated_fields)
      redirect "/systems/#{system_id}/roles/edit/#{role_id}?status=success&message=Permiso actualizado correctamente"
    rescue Mongoid::Errors::DocumentNotFound
      redirect "/systems/#{system_id}/roles/edit/#{role_id}?status=error&message=No se encontró el permiso con el ID especificado"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/systems/#{system_id}/roles/edit/#{role_id}?status=error&message=Ocurrió un error al actualizar el permiso"
    end
  end

  get '/systems/:system_id/roles/:role_id/permissions/delete/:_id' do
    begin
      _id = params[:_id]
      permission = Permission.find(_id)
      permission.destroy  
      redirect "/systems/#{params[:system_id]}/roles/edit/#{params[:role_id]}?status=success&message=Permiso eliminado</b>"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/systems?status=error&message=Ha ocurrido un error en editar el permiso"
    end
  end
end