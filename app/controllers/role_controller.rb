class RoleController < ApplicationController
  before do
    public_routes = ['/roles']
    unless public_routes.include?(request.path_info) 
      #check_session_true
    end
  end

  get '/systems/:system_id/roles' do
    # request
    system_id = params[:system_id]
    message = params[:message] || nil
    status = params[:status] || nil
    search_name = params[:name] || nil
    btn_search = params[:btn_search] || nil
    page = params[:page] || 1
    # blogic
    step = 10.0
    offset = (page.to_i - 1) * step.to_i
    if search_name and btn_search
      roles_count = System.count_roles(BSON::ObjectId(system_id), search_name)
      roles = System.fetch_roles(BSON::ObjectId(system_id), step, 0, search_name)
    elsif search_name and (not btn_search)
      roles_count = System.count_roles(BSON::ObjectId(system_id), search_name)
      roles = System.fetch_roles(BSON::ObjectId(system_id), step, offset, search_name)
    else
      roles_count = System.count_roles(BSON::ObjectId(system_id))
      roles = System.fetch_roles(BSON::ObjectId(system_id), step, offset)
    end
    # response
    locals = { 
      title: 'Gestión de Roles del Sistema', 
      user: 'Usuario demo',
      error: false,
      status: status,
      message: message,
      roles: roles,
      search_name: search_name, 
      page: page.to_i, 
      system_id: system_id, 
      total_pages: (roles_count / step).ceil
    }
    erb :'role/index', layout: :'layouts/application', locals: locals
  end
  
  get '/systems/:system_id/roles/create' do
    locals = { 
      title: 'Agregar Rol a Sistema', 
      user: 'Usuario demo',
      subtile: 'Agregar Rol a Sistema',
      system_id: params[:system_id], 
      role: nil,
      error: false
    }
    erb :'role/detail', layout: :'layouts/application', locals: locals
  end

  post '/systems/:system_id/roles' do
    begin
      system_id = params[:system_id]
      name = params[:name]
      description = params[:description]
      role = Role.create!(
        name: name,
        description: description,
        created: Time.now,
        updated: Time.now,
        permission_ids: []
      )
      system = System.find(BSON::ObjectId(system_id))
      system.push(role_ids: role.id)
      redirect "/systems/#{system_id}/roles/edit/#{role.id}?status=success&message=Rol creado, id: <b>#{role.id}</b>"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/systems/#{system_id}/roles?status=error&message=Ha ocurrido un error en guardar el rol del sistema"
    end
  end

  get '/roles/delete/:_id' do
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

  get '/systems/:system_id/roles/edit/:_id' do
    begin
      _id = params[:_id]
      system_id = params[:system_id]
      role = Role.find(_id)
      locals = { 
        title: 'Editar Rol', 
        user: 'Usuario demo',
        subtile: 'Editar Rol',
        error: false,
        role: role,
        system_id: system_id,
      }
      erb :'role/detail', layout: :'layouts/application', locals: locals
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/systems/#{system_id}/roles?status=error&message=Ha ocurrido un error en editar el sistema"
    end
  end

  post '/systems/:system_id/roles/:_id' do
    begin
      system_id = params[:system_id]
      role = Role.find(params[:_id])
      updated_fields = {}
      updated_fields[:name] = params[:name] if params[:name]
      updated_fields[:description] = params[:description] if params[:description]
      updated_fields[:updated] = Time.now
      role.update!(updated_fields)
      redirect "/systems/#{system_id}/roles?status=success&message=Rol actualizado correctamente"
    rescue Mongoid::Errors::DocumentNotFound
      redirect "/roles?status=error&message=No se encontró el sistema con el ID especificado"
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      redirect "/roles?status=error&message=Ocurrió un error al actualizar el sistema"
    end
  end
  
end