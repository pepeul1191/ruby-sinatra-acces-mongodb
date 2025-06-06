require 'mongoid'

class System
  include Mongoid::Document
  field :name, type: String
  field :repo, type: String
  field :created, type: DateTime, default: -> { Time.now }
  field :updated, type: DateTime
  field :role_ids, type: Array, default: [], as: :role_ids
  field :user_ids, type: Array, default: [], as: :user_ids

  def self.fetch_roles(_id, step, offset, search_name = nil) # (BSON::ObjectId, float, int, str) -> Array[Role]
    pipeline = [
      {
        "$match" => { "_id" => _id }
      },
      {
        "$lookup" => {
          "from" => "roles",               # Colección relacionada
          "localField" => "role_ids",      # Campo en "systems" con los ObjectIds
          "foreignField" => "_id",         # Campo en "roles" que se relaciona con "role_ids"
          "as" => "roles_info"             # Nombre del campo para los datos combinados
        }
      },
      {
        "$unwind" => "$roles_info"         # Descomponer el array roles_info en documentos individuales
      },
      {
        "$replaceRoot" => {
          "newRoot" => {                   # Reemplazar el documento raíz con cada elemento de roles_info
            "_id" => { "$toString" => "$roles_info._id" },
            "name" => "$roles_info.name",
            "description" => "$roles_info.description",
            "created" => "$roles_info.created",
            "updated" => "$roles_info.updated"
          }
        }
      }
    ]
    # Agregar filtro con $regex si search_name no es nil
    if search_name
      pipeline << { "$match" => { "name" => { "$regex" => search_name, "$options" => "i" } } }
    end
    # Agregar limit y offset
    pipeline.push(
      { "$skip" => offset },                # Saltar los primeros 'offset' documentos
      { "$limit" => step }                  # Limitar a 'step' documentos
    )
    # Convertir los resultados en instancias de Role
    self.collection.aggregate(pipeline).map do |doc|
      Role.new(
        id: doc["_id"],
        name: doc["name"],
        description: doc["description"],
        created: doc["created"],
        updated: doc["updated"]
      )
    end
  end
  
  def self.count_roles(_id, search_name = nil) # (BSON::ObjectId, str) -> int
    pipeline = [
      {
        "$match" => { "_id" => _id }
      },
      {
        "$lookup" => {
          "from" => "roles",               # Colección relacionada
          "localField" => "role_ids",      # Campo en "systems" con los ObjectIds
          "foreignField" => "_id",         # Campo en "roles" que se relaciona con "role_ids"
          "as" => "roles_info"             # Nombre del campo para los datos combinados
        }
      },
      {
        "$unwind" => "$roles_info"         # Descomponer el array roles_info en documentos individuales
      },
      {
        "$count" => "total_roles"          # Contar los documentos resultantes
      }
    ]
    if search_name
      pipeline << {
        "$match" => {
          "roles_info.name" => { "$regex" => search_name, "$options" => "i" }
        }
      }
      # Agregar la etapa de conteo
      pipeline << {
        "$count" => "total_roles"            # Contar los documentos resultantes
      }
    end
    # Ejecutar el pipeline y retornar el resultado
    result = self.collection.aggregate(pipeline).first
    result ? result["total_roles"] : 1
  end
end
