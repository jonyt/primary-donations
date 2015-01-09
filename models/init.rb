require 'sequel'

DB = Sequel.connect(ENV['DATABASE_URL']) unless defined? DB
raise "Unable to connect to #{ENV['DATABASE_URL']}" unless DB.test_connection

require_relative 'party'
require_relative 'donor'
require_relative 'candidate'
require_relative 'donation'