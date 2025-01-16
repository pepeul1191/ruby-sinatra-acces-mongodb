require 'mongoid'

class Role
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :created, type: DateTime, default: -> { Time.now }
  field :updated, type: DateTime
  field :permission_ids, type: Array, default: [], as: :permission_ids

  def self.fetch_permissions(_id, step, offset, search_name = nil) # (BSON::ObjectId, float, int, str) -> Array[Role]
    []
  end
  
  def self.count_permissions(_id, search_name = nil) # (BSON::ObjectId, str) -> int
    0
  end
end