require 'mongoid'

class Permission
  include Mongoid::Document
  field :name, type: String
  field :description, type: String
  field :created, type: DateTime, default: -> { Time.now }
  field :updated, type: DateTime
end