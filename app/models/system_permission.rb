require 'mongoid'

class SystemPermission
  include Mongoid::Document
  field :system_id, type: BSON::ObjectId
  field :permission_ids, type: Array, default: [], as: :permission_ids
  field :created, type: DateTime, default: -> { Time.now }
  field :updated, type: DateTime

  embedded_in :user
end
