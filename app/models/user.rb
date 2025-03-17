require 'mongoid'

class User
  include Mongoid::Document
  field :name, type: String
  field :password, type: String
  field :activation_key, type: String
  field :reset_key, type: String
  field :email, type: String
  field :activated, type: Boolean
  # field :permission_ids, type: Array, default: [], as: :permission_ids
  # field :roles_ids, type: Array, default: [], as: :roles_ids
  # field :tokens, type: Array, default: [], as: :tokens
  field :created, type: DateTime, default: -> { Time.now }
  field :updated, type: DateTime
end