require 'bundler'
require 'bundler/setup'
Bundler.require

configure :development do
  set :database, 'sqlite3:db/database.db'
  set :show_exceptions, true
end

configure :production do
  set :database, 'postgres://user:password@localhost/mydb'
  set :show_exceptions, false
end

require_all 'config/initializers'
require_all 'app/helpers'
require_all 'app/models'
require_all 'app/controllers'
require_all 'app/apis'
