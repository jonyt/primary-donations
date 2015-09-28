require 'sequel'

class Candidate < Sequel::Model
	one_to_many :donations	

  # attr_reader :donations

  def from_params(params)    
    self.web_id = params['ID']
    self.name = params['Name']
    self
    # @donations = []
    # @party_id = party_id
  end

  # def <<(donation)
  #   @donations << donation
  # end

  def to_params
    {body: {action: 'gds', d: d_param}}
  end

  private

  def d_param
    '{"PartyID":null,"EntityID":"' + web_id.to_s + '","EntityTypeID":1,"PublicationSearchType":"1","GD_Name":"","CityID":""
,"CountryID":"","FromDate":"","ToDate":"","FromSum":"","ToSum":"","ID":null,"State":0,"URL":null,"IsControl"
:false,"IsUpdate":false}'
  end
end