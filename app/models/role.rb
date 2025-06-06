require 'mongoid'

class Role
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :created, type: DateTime, default: -> { Time.now }
  field :updated, type: DateTime
  field :permission_ids, type: Array, default: [], as: :permission_ids

  def self.fetch_permissions(_id, step, offset, search_name = nil) # (BSON::ObjectId, float, int, str) -> Array[Role]
    pipeline = [
      {
        "$match" => { "_id" => _id }
      },
      {
        "$lookup" => {
          "from" => "permissions",               # Colección relacionada
          "localField" => "permission_ids",      # Campo en "systems" con los ObjectIds
          "foreignField" => "_id",         # Campo en "permissions" que se relaciona con "permission_ids"
          "as" => "permissions_info"             # Nombre del campo para los datos combinados
        }
      },
      {
        "$unwind" => "$permissions_info"         # Descomponer el array permissions_info en documentos individuales
      },
      {
        "$replaceRoot" => {
          "newRoot" => {                   # Reemplazar el documento raíz con cada elemento de permissions_info
            "_id" => { "$toString" => "$permissions_info._id" },
            "name" => "$permissions_info.name",
            "description" => "$permissions_info.description",
            "created" => "$permissions_info.created",
            "updated" => "$permissions_info.updated"
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
  
  def self.count_permissions(_id, search_name = nil) # (BSON::ObjectId, str) -> int
    pipeline = [
      {
        "$match" => { "_id" => _id }
      },
      {
        "$lookup" => {
          "from" => "permissions",               # Colección relacionada
          "localField" => "permission_ids",      # Campo en "systems" con los ObjectIds
          "foreignField" => "_id",         # Campo en "permissions" que se relaciona con "permission_ids"
          "as" => "permissions_info"             # Nombre del campo para los datos combinados
        }
      },
      {
        "$unwind" => "$permissions_info"         # Descomponer el array permissions_info en documentos individuales
      },
      {
        "$count" => "total_permissions"          # Contar los documentos resultantes
      }
    ]
    if search_name
      pipeline << {
        "$match" => {
          "permissions_info.name" => { "$regex" => search_name, "$options" => "i" }
        }
      }
      # Agregar la etapa de conteo
      pipeline << {
        "$count" => "total_permissions"            # Contar los documentos resultantes
      }
    end
    # Ejecutar el pipeline y retornar el resultado
    result = self.collection.aggregate(pipeline).first
    result ? result["total_permissions"] : 1
  end

  def as_json(options = {})
    attrs = {
      _id: id.to_s,
      name: name,
      description: description,
      created: created,
      updated: updated,
    }

    if options[:only]
      attrs.slice(*options[:only])
    elsif options[:except]
      attrs.except(*options[:except])
    else
      attrs
    end
  end
end