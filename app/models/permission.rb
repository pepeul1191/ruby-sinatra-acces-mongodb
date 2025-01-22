require 'mongoid'

class Permission
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :created, type: DateTime, default: -> { Time.now }
  field :updated, type: DateTime
  field :role_ids, type: Array, default: [], as: :role_ids
end