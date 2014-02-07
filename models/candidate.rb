require 'sequel'

class Candidate < Sequel::Model
	one_to_many :donations	
end