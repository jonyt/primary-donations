require 'time'
require 'logger'
require 'httparty'

$logger = Logger.new(STDOUT)

class Crawler
  include HTTParty
  base_uri 'https://statements.mevaker.gov.il/Handler/GuarantyDonationPublisherHandler.ashx'

  def get_candidates(parties)
    parties.each do |party|
      $logger.info "Getting candidates for party [#{party.name}]"
      response = self.class.post('', party.to_params)
      # puts response.parsed_response.inspect
      response.parsed_response.each do |candidate_data|
        party << Candidate.new(candidate_data)
      end
      $logger.info "[#{party.name}] has #{party.candidates.size} candidates"
    end
  end

  def get_candidate_donations(candidate)
    response = self.class.post('', candidate.to_params)
    response.parsed_response.first.each do |donation_data|
      candidate << Donation.new(donation_data)
    end
  end
end

class Party
  attr_reader :id, :name, :candidates

  def initialize(id, name)
    @id = id
    @name = name
    @candidates = []
  end

  def <<(candidate)
    @candidates << candidate
  end

  def to_params
    {body: {action: 'gcbp', p: @id}}
  end
end

class Candidate
  attr_reader :donations

  def initialize(params)
    @id = params['ID']
    @name = params['Name']
    @donations = []
  end

  def <<(donation)
    @donations << donation
  end

  def to_params
    {body: {action: 'gds', d: d_param}}
  end

  private

  def d_param
    '{"PartyID":null,"EntityID":"' + @id.to_s + '","EntityTypeID":1,"PublicationSearchType":"1","GD_Name":"","CityID":""
,"CountryID":"","FromDate":"","ToDate":"","FromSum":"","ToSum":"","ID":null,"State":0,"URL":null,"IsControl"
:false,"IsUpdate":false}'
  end
end

class Donation
  attr_reader :donor, :shekels, :date

  def initialize(params)
    @donor   = params['GD_Name']
    @country = params['Country']
    @shekels = params['GD_Sum']
    @date    = Time.at(params['GD_Date'].gsub(/\D/, '').to_i / 1000).to_date 
  end
end

parties = [
  Party.new(14, 'אגודת החרדים – דגל התורה'),
  Party.new(8, 'ארץ ישראל שלנו'),
  Party.new(1, 'בל"ד- אלתגמוע אלווטני אלדמוקרטי'),
  Party.new(3, 'הליכוד תנועה לאומית'),
  Party.new(7, 'התקווה'),
  Party.new(11, 'חד"ש- המפלגה הקומוניסטית הישראלית'),
  Party.new(15, 'יש עתיד – בראשות יאיר לפיד'),
  Party.new(12, 'ישראל ביתנו'),
  Party.new(2, 'מפד"ל החדשה- הבית היהודי'),
  Party.new(4, 'מפלגת העבודה הישראלית'),
  Party.new(16, 'מפלגת העצמאות'),
  Party.new(5, 'מר"צ - יחד'),
  Party.new(13, 'קדימה'),
  Party.new(9, 'רשימת האיחוד הערבי'),
  Party.new(10, 'ש"ס – התאחדות הספרדים העולמית שומרי תורה'),
  Party.new(17, 'תע"ל-התנועה הערבית להתחדשות'),
  Party.new(6, 'תקומה')
]

crawler = Crawler.new
crawler.get_candidates(parties)
parties.each do |party|
  party.candidates.each do |candidate|
    crawler.get_candidate_donations(candidate)
  end  
end

# puts parties.inspect





# parties = {
#   14 => 'אגודת החרדים – דגל התורה',
#   8 => 'ארץ ישראל שלנו ',
#   1 => 'בל"ד- אלתגמוע אלווטני אלדמוקרטי ',
#   3 => 'הליכוד תנועה לאומית ',
#   7 => 'התקווה',
#   11 => 'חד"ש- המפלגה הקומוניסטית הישראלית',
#   15 => 'יש עתיד – בראשות יאיר לפיד',
#   12 => 'ישראל ביתנו',
#   2 => 'מפד"ל החדשה- הבית היהודי',
#   4 => 'מפלגת העבודה הישראלית ',
#   16 => 'מפלגת העצמאות',
#   5 => 'מר"צ - יחד',
#   13 => 'קדימה',
#   9 => 'רשימת האיחוד הערבי',
#   10 => 'ש"ס – התאחדות הספרדים העולמית שומרי תורה',
#   17 => 'תע"ל-התנועה הערבית להתחדשות',
#   6 => 'תקומה'
# }