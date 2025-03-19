require 'mongoid'

class User
  include Mongoid::Document
  field :name, type: String
  field :password, type: String
  field :activation_key, type: String
  field :reset_key, type: String
  field :email, type: String
  field :activated, type: Boolean
  # field :roles_ids, type: Array, default: [], as: :roles_ids
  # field :tokens, type: Array, default: [], as: :tokens
  field :created, type: DateTime, default: -> { Time.now }
  field :updated, type: DateTime
  
  embeds_many :permissions, class_name: "SystemPermission"

  def self.fetch_system_users(system_id, step, offset, search_name = nil, search_email = nil, registered = nil)
    pipeline = [
      {
        "$lookup" => {
          "from" => "systems",
          "localField" => "_id",
          "foreignField" => "user_ids",
          "as" => "system_data"
        }
      },
      {
        "$addFields" => {
          "registered" => {
            "$cond" => {
              "if" => {
                "$gt" => [
                  {
                    "$size" => {
                      "$filter" => {
                        "input" => "$system_data",
                        "as" => "sys",
                        "cond" => { "$eq" => ["$$sys._id", BSON::ObjectId(system_id)] }
                      }
                    }
                  }, 
                  0
                ]
              },
              "then" => true,
              "else" => false
            }
          }
        }
      }
    ]
  
    # Construcción de filtros dinámicos (antes de `$lookup`)
    filters = {}
    filters["name"] = { "$regex" => search_name, "$options" => "i" } if search_name
    filters["email"] = { "$regex" => search_email, "$options" => "i" } if search_email
    # Si hay filtros de `name` o `email`, aplicarlos antes de `$lookup`
    pipeline.prepend({ "$match" => filters }) unless filters.empty?
    # Solo agregar el filtro de `registered` si es `true` o `false`
    pipeline.push({ "$match" => { "registered" => registered } }) if [true, false].include?(registered)
    # Agregar paginación
    pipeline.push(
      { "$skip" => offset },
      { "$limit" => step }
    )
    # Ejecutar la consulta y devolver los resultados
    self.collection.aggregate(pipeline).to_a
  end  
  
  def self.count_system_users(system_id, search_name = nil, search_email = nil, registered = nil)
    pipeline = [
      {
        "$lookup" => {
          "from" => "systems",
          "localField" => "_id",
          "foreignField" => "user_ids",
          "as" => "system_data"
        }
      },
      {
        "$addFields" => {
          "registered" => {
            "$cond" => {
              "if" => {
                "$gt" => [
                  {
                    "$size" => {
                      "$filter" => {
                        "input" => "$system_data",
                        "as" => "sys",
                        "cond" => { "$eq" => ["$$sys._id", BSON::ObjectId(system_id)] }
                      }
                    }
                  }, 
                  0
                ]
              },
              "then" => true,
              "else" => false
            }
          }
        }
      }
    ]
    # Construcción de filtros dinámicos (antes de `$lookup`)
    filters = {}
    filters["name"] = { "$regex" => search_name, "$options" => "i" } if search_name
    filters["email"] = { "$regex" => search_email, "$options" => "i" } if search_email
    # Aplicar filtros de `name` y `email` antes de `$lookup`
    pipeline.prepend({ "$match" => filters }) unless filters.empty?
    # 🚀 Mover el `$match` de `registered` DESPUÉS de `$addFields`
    pipeline.push({ "$match" => { "registered" => registered } }) if [true, false].include?(registered)
    # Agregar conteo
    pipeline.push({ "$count" => "total_users" })
    # Ejecutar consulta y devolver el resultado
    result = self.collection.aggregate(pipeline).first
    return result ? result["total_users"] : 0
  end
end