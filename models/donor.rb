require 'sequel'

class Donor < Sequel::Model	
	one_to_many :donations

  def self.find_or_create_from_params(params)
    name = params['GD_Name']
    country = params['Country']
    donor = find_or_create(name: name)
    donor.update(country: country)
    donor
  end
end