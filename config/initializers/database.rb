require 'mongo'
require 'mongoid'

DB = Mongo::Client.new('mongodb://127.0.0.1:27017/chat')
Mongoid.load!('./config/database.yml', :development)