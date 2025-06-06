class RoleApi < ApplicationController
  before do
    public_routes = ['/roles']
    unless public_routes.include?(request.path_info) 
      #check_session_true
    end
  end

  get '/apis/v1/roles/:role_id/permissions' do
    # request
    role_id = params[:role_id]
    response = {}
    status = 200
    # blogic
    begin
      step = 1000.0
      offset = 0
      roles = Role.fetch_permissions(BSON::ObjectId(role_id), step, offset)
      roles = roles.map { |r| r.as_json(only: [:_id, :name]) }
      response = roles
    rescue => e
      puts "Error: #{e.message}"
      puts e.backtrace
      response = {
        message: 'Ocurrió un error al buscar los permisos del rol',
        detail: e.message
      }
    end
    # response
    content_type :json
    status status
    response.to_json
  end
end