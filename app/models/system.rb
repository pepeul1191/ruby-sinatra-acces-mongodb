require 'mongoid'

class System
  include Mongoid::Document
  field :name, type: String
  field :repo, type: String
  field :created_at, type: DateTime, default: -> { Time.now }
  field :updated_at, type: DateTime
end