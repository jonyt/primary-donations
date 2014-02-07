require 'sequel'

class Donor < Sequel::Model	
	one_to_many :donations
end