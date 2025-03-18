require 'mongoid'

class User
  include Mongoid::Document
  field :name, type: String
  field :password, type: String
  field :activation_key, type: String
  field :reset_key, type: String
  field :email, type: String
  field :activated, type: Boolean
  # field :permission_ids, type: Array, default: [], as: :permission_ids
  # field :roles_ids, type: Array, default: [], as: :roles_ids
  # field :tokens, type: Array, default: [], as: :tokens
  field :created, type: DateTime, default: -> { Time.now }
  field :updated, type: DateTime

  def self.fetch_system_users(system_id, step, offset, search_name = nil, search_email = nil)
    pipeline = [
      {
        "$lookup" => {
          "from" => "systems",             # Relacionar con systems
          "localField" => "_id",           # ID de usuario
          "foreignField" => "user_ids",    # Lista de usuarios en systems
          "as" => "system_data"            # Campo con la información del sistema
        }
      },
      {
        "$addFields" => {
          "filtered_systems" => {
            "$filter" => {
              "input" => "$system_data",
              "as" => "sys",
              "cond" => { "$eq" => ["$$sys._id", system_id] } # Filtrar sistemas por ID
            }
          }
        }
      },
      {
        "$addFields" => {
          "registered" => { "$gt" => [{ "$size" => "$system_data" }, 0] } # Verifica si está registrado en al menos un sistema
        }
      },
      {
        "$project" => {
          "_id" => { "$toString" => "$_id" }, # Convertir _id a string
          "name" => 1,
          "email" => 1,
          "activated" => 1,
          "registered" => 1
        }
      }
    ]
    # Construcción de filtros dinámicos
    filters = {}
    filters["name"] = { "$regex" => search_name, "$options" => "i" } if search_name
    filters["email"] = { "$regex" => search_email, "$options" => "i" } if search_email
    pipeline.prepend({ "$match" => filters }) unless filters.empty?
    # Agregar paginación
    pipeline.push(
      { "$skip" => offset }, # Saltar los primeros "offset" documentos
      { "$limit" => step }   # Limitar a "step" documentos
    )
    # Convertir los resultados en instancias de User
    docs = []
    self.collection.aggregate(pipeline).map do |doc|
      docs.push(doc)
    end
    return docs
  end  

  def self.count_system_users(system_id, search_name = nil, search_email = nil)
    pipeline = [
      {
        "$lookup" => {
          "from" => "systems",             # Relacionar con systems
          "localField" => "_id",           # ID de usuario
          "foreignField" => "user_ids",    # Lista de usuarios en systems
          "as" => "system_data"            # Campo con la información del sistema
        }
      },
      {
        "$addFields" => {
          "filtered_systems" => {
            "$filter" => {
              "input" => "$system_data",
              "as" => "sys",
              "cond" => { "$eq" => ["$$sys._id", system_id] } # Filtrar sistemas por ID
            }
          }
        }
      },
    ]
    # Construcción de filtros dinámicos
    filters = {}
    filters["name"] = { "$regex" => search_name, "$options" => "i" } if search_name
    filters["email"] = { "$regex" => search_email, "$options" => "i" } if search_email
    pipeline.prepend({ "$match" => filters }) unless filters.empty?
    # Agregar conteo
    pipeline.push({ "$count" => "total_users" })
    # Ejecutar consulta y devolver el resultado
    result = self.collection.aggregate(pipeline).first
    return result ? result["total_users"] : 0
  end  
end