require 'mongoid'

class Role
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :created, type: DateTime, default: -> { Time.now }
  field :updated, type: DateTime
  field :permission_ids, type: Array, default: [], as: :permission_ids
end