require 'httparty'
require 'pry-byebug'
require 'json'
require 'dotenv'

Dotenv.load

require_relative '../models/init'

def get_data(url, params)
  resp = HTTParty.post(url, :body => params) 
  raise "Request failed for #{url}" if resp.response.code != '200'
  resp.parsed_response
end

parties = get_data('https://statements.mevaker.gov.il/Handler/GuarantyDonationPublisherHandler.ashx', {:action => 'gpn'})

parties.each do |party|
  next unless party["ID"] == 4
  candidates = get_data('https://statements.mevaker.gov.il/Handler/GuarantyDonationPublisherHandler.ashx', {:action => 'gcbp', :p => party['ID']})
  db_party = Party.find_or_create(:name => party['Name'])
  puts "Party: #{db_party.name}"
  candidates.each do |candidate|
    db_candidate = Candidate.find_or_create(:name => candidate['Name'], :party_id => db_party.id)
    puts "Candidate: #{db_candidate.name}"
    donations = get_data(
      'https://statements.mevaker.gov.il/Handler/GuarantyDonationPublisherHandler.ashx',
      {
        :action => 'gds',
        :d => "{\"PartyID\":null,\"EntityID\":\"#{candidate['ID']}\",\"EntityTypeID\":1,\"PublicationSearchType\":\"1\",\"GD_Name\":\"\",\"CityID\":\"\",\"CountryID\":\"\",\"FromDate\":\"\",\"ToDate\":\"\",\"FromSum\":\"\",\"ToSum\":\"\",\"ID\":null,\"State\":0,\"URL\":null,\"IsControl\":false,\"IsUpdate\":false}"
      }
    )
    donations.each do |donation|      
      puts donation.inspect
      next unless donation.is_a?(Array) && donation.size > 0
      binding.pry
      
      db_donor = Donor.find_or_create(:name => donation['GD_Name'])
      puts "Donor: #{db_donor.name}"
      date = Time.at(candidate['GD_Date'].match(/Date\((\d+)000\)/)[1].to_i)
      db_donation = Donation.create(
        :candidate_id => db_candidate.id, 
        :donor_id => db_donor.id, 
        :amount => donation['GD_Sum'], 
        :currency => 'nis', 
        :date => date, 
        :country => donation['Country']
      )
      puts db_donation.inspect
      exit
    end
  end
end
