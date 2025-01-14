require 'mongoid'

class System
  include Mongoid::Document
  field :name, type: String
  field :repo, type: String
  field :created, type: DateTime, default: -> { Time.now }
  field :updated, type: DateTime
  field :role_ids, type: Array, default: [], as: :role_ids

  def self.fetch_roles(_id) # (BSON::ObjectId) -> Enumerator
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
end
