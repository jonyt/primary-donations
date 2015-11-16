require 'sequel'
require 'open-uri'
require_relative 'old_candidate_parser'

DB = Sequel.connect('postgres://yoni:telaviv@localhost:5432/primary_donations')
require_relative '../models/candidate'
require_relative '../models/donor'
require_relative '../models/donation'

unless ARGV.size == 2
  puts "Usage: #{$0} file party_id"
  exit
end
party_id = Integer(ARGV[1])

File.open(ARGV[0]).each do |line|
  url, candidate_id_string = line.split(', ')
  url = 'https://web.archive.org/web/20140803081026/' + url
  candidate_id = candidate_id_string.to_i
  parser = loop do 
    count = 0
    begin
      parser = OldCandidateParser.new(url)
      break parser  
    rescue Net::ReadTimeout => e
      count += 1
      puts "Retrying #{count}"  
    end
  end
  
  candidate = candidate_id > 0 ?
                Candidate[candidate_id] :
                Candidate.create(name: parser.candidate_name, party_id: party_id)

  puts "Candidate: #{candidate.name.reverse}"              
  parser.donations.each do |donation|              
    donor = Donor.find_or_create(name: donation.donor, country: donation.address)
    puts "Donation: #{donor.name.reverse} => #{candidate.name.reverse} - #{donation.shekels}"
    Donation.create(
      candidate_id: candidate.id,
      donor_id: donor.id,
      amount: donation.shekels,
      date: donation.date
    )
  end
end