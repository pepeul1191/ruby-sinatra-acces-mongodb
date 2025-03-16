class PermissionController < ApplicationController
  before do
    public_routes = ['/roles']
    unless public_routes.include?(request.path_info) 
      #check_session_true
    end
  end

  get '/roles/:role_id/permissions' do
    # request
    role_id = params[:role_id]
    message = params[:message] || nil
    status = params[:status] || nil
    search_name = params[:name] || nil
    btn_search = params[:btn_search] || nil
    page = params[:page] || 1
    # blogic
    step = 10.0
    offset = (page.to_i - 1) * step.to_i
    if search_name and btn_search
      permissions_count = Role.count_permissions(BSON::ObjectId(role_id), search_name)
      permissions = Role.fetch_permissions(BSON::ObjectId(role_id), step, 0, search_name)
    elsif search_name and (not btn_search)
      permissions_count = Role.count_permissions(BSON::ObjectId(role_id), search_name)
      permissions = Role.fetch_permissions(BSON::ObjectId(role_id), step, offset, search_name)
    else
      permissions_count = Role.count_permissions(BSON::ObjectId(role_id))
      permissions = Role.fetch_permissions(BSON::ObjectId(role_id), step, offset)
    end
    # response
    locals = { 
      title: 'Gestión de Permisos del Rol', 
      user: 'Usuario demo',
      error: false,
      status: status,
      message: message,
      permissions: permissions,
      search_name: search_name, 
      page: page.to_i, 
      role_id: role_id, 
      total_pages: (permissions_count / step).ceil
    }
    erb :'permission/index', layout: :'layouts/application', locals: locals
  end
  
  get '/roles/:role_id/permissions/create' do
    locals = { 
      title: 'Agregar Permiso a Rol', 
      user: 'Usuario demo',
      subtile: 'Agregar Permiso a Rol',
      role_id: params[:role_id], 
      permission: nil,
      error: false
    }
    erb :'permission/detail', layout: :'layouts/application', locals: locals
  end

  post '/roles/:role_id/permissions' do
    begin
      role_id = params[:role_id]
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
      redirect "/roles/#{role_id}/permissions?status=success&message=Permiso creado, id: <b>#{permission.id}</b>"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/roles/#{role_id}/permissions?status=error&message=Ha ocurrido un error en guardar el permiso del rol"
    end
  end

  get '/roles/:role_id/permissions/delete/:_id' do
    role_id = params[:role_id]
    begin
      _id = params[:_id]
      permission = Permission.find(_id)
      permission.destroy  
      redirect "/roles/#{role_id}/permissions?status=success&message=Permiso eliminado</b>"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/roles/#{role_id}/permissions?status=error&message=Ha ocurrido un error en editar el sistema"
    end
  end

  get '/roles/:role_id/permissions/edit/:_id' do
    begin
      _id = params[:_id]
      role_id = params[:role_id]
      permission = Permission.find(_id)
      locals = { 
        title: 'Editar Rol', 
        user: 'Usuario demo',
        subtile: 'Editar Rol',
        error: false,
        permission: permission,
        role_id: role_id,
      }
      erb :'permission/detail', layout: :'layouts/application', locals: locals
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/roles/#{role_id}/permissions?status=error&message=Ha ocurrido un error en editar el permiso"
    end
  end

  post '/roles/:role_id/permissions/:_id' do
    begin
      role_id = params[:role_id]
      permission = Permission.find(params[:_id])
      updated_fields = {}
      updated_fields[:name] = params[:name] if params[:name]
      updated_fields[:description] = params[:description] if params[:description]
      updated_fields[:updated] = Time.now
      permission.update!(updated_fields)
      redirect "/roles/#{role_id}/permissions?status=success&message=Permiso actualizado correctamente"
    rescue Mongoid::Errors::DocumentNotFound
      redirect "/roles/#{role_id}/permissions?status=error&message=No se encontró el permiso con el ID especificado"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/roles/#{role_id}/permissions?status=error&message=Ocurrió un error al actualizar el permiso"
    end
  end
  
end