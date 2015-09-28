require 'time'
require 'logger'
require 'httparty'
require 'sequel'

Sequel.connect('postgres://yoni:telaviv@localhost:5432/primary_donations')
require_relative '../models/party'
require_relative '../models/candidate'
require_relative '../models/donor'
require_relative '../models/donation'

$logger = Logger.new(STDOUT)

class Crawler
  include HTTParty
  base_uri 'https://statements.mevaker.gov.il/Handler/GuarantyDonationPublisherHandler.ashx'

  def get_candidates(parties)
    parties.each do |party|
      $logger.info "Getting candidates for party [#{party.name}]"
      response = self.class.post('', party.to_params)
      response.parsed_response.each do |candidate_params|
        party.add_candidate(Candidate.new.from_params(candidate_params))
      end
      $logger.info "[#{party.name}] has #{party.candidates.size} candidates"
    end
  end

  def get_candidate_donations(candidate)
    response = self.class.post('', candidate.to_params)
    response.parsed_response.first.each do |donation_params|
      donor = Donor.find_or_create_from_params(donation_params)
      donation = Donation.new.from_params(donation_params)
      donation.donor = donor
      donation.candidate = candidate
      donation.save
      $logger.info "Saved donation #{donation.inspect}"
    end
  end
end

parties = [
  Party.find_or_create(web_id: 14, name: 'אגודת החרדים – דגל התורה'),
  Party.find_or_create(web_id: 8, name: 'ארץ ישראל שלנו'),
  Party.find_or_create(web_id: 1, name: 'בל"ד- אלתגמוע אלווטני אלדמוקרטי'),
  Party.find_or_create(web_id: 3, name: 'הליכוד תנועה לאומית'),
  Party.find_or_create(web_id: 7, name: 'התקווה'),
  Party.find_or_create(web_id: 11, name: 'חד"ש- המפלגה הקומוניסטית הישראלית'),
  Party.find_or_create(web_id: 15, name: 'יש עתיד – בראשות יאיר לפיד'),
  Party.find_or_create(web_id: 12, name: 'ישראל ביתנו'),
  Party.find_or_create(web_id: 2, name: 'מפד"ל החדשה- הבית היהודי'),
  Party.find_or_create(web_id: 4, name: 'מפלגת העבודה הישראלית'),
  Party.find_or_create(web_id: 16, name: 'מפלגת העצמאות'),
  Party.find_or_create(web_id: 5, name: 'מר"צ - יחד'),
  Party.find_or_create(web_id: 13, name: 'קדימה'),
  Party.find_or_create(web_id: 9, name: 'רשימת האיחוד הערבי'),
  Party.find_or_create(web_id: 10, name: 'ש"ס – התאחדות הספרדים העולמית שומרי תורה'),
  Party.find_or_create(web_id: 17, name: 'תע"ל-התנועה הערבית להתחדשות'),
  Party.find_or_create(web_id: 6, name: 'תקומה')
]

crawler = Crawler.new
crawler.get_candidates(parties)
parties.each do |party|
  party.candidates.each do |candidate|
    crawler.get_candidate_donations(candidate)
  end  
end