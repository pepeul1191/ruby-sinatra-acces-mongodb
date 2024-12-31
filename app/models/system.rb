require 'mongoid'

class System
  include Mongoid::Document
  field :name, type: String
  field :repo, type: String
  field :created, type: DateTime, default: -> { Time.now }
  field :updated, type: DateTime
end