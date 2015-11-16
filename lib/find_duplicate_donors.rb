require 'sequel'
require 'io/console'

DB = Sequel.connect('postgres://yoni:telaviv@localhost:5432/primary_donations')
require_relative '../models/donation'
require_relative '../models/donor'

def reverse_unless_english(string)
  string.match(/[a-zA-Z]/) ? string : string.reverse
end  

def coalesce_donors(from, others)
  puts "Before. Number of donations from: #{Donation.where(donor_id: from.id).count}"
  puts "Before. Number of donations others: " + 
    "#{Donation.where('donor_id IN ?', others.map{|e| e.id}).count}"
  others.each do |donor|
    donations = Donation.where(donor_id: donor.id)
    donations.update(donor_id: from.id)
  end  
  puts "After. Number of donations from: #{Donation.where(donor_id: from.id).count}"
  puts "After. Number of donations others: " + 
    "#{Donation.where('donor_id IN ?', others.map{|e| e.id}).count}"
  puts "***************\n\n"
end

donors = Donor.all
name_to_donors = donors.inject({}){|mem, donor| 
  if donor.donations.size > 0
    mem[donor.name.downcase] = mem.fetch(donor.name.downcase, []) << donor
  end  
  mem
}

ii = 0
name_to_donors.each_pair do |name, donors|
  ii += 1
  next if ii / name_to_donors.size.to_f * 100 < 52.0
  next if donors.size < 2 || 
    donors.all?{|donor| donor.country.nil? } ||
    (donors.size == 2 && donors.any?{|donor| donor.country == 'ישראל' })
  puts reverse_unless_english(name)
  donors.each_with_index do |donor, i|
    puts "#{i + 1}: #{reverse_unless_english(donor.country)}"
  end
  input = STDIN.gets.chomp
  case input
  when 'y'
    raise "Not allowed" if donors.size != 2
    coalesce_donors(donors.first, Array(donors.last))
  when 'n'      
  when /(\d,?)+/    
    indexes = input.split(/[,\.]/).map { |e| Integer(e) }
    from = donors[indexes.first - 1]
    others = indexes.drop(1).inject([]){|mem, i| mem << donors[i - 1]}
    coalesce_donors(from, others)
  else
    puts '??'
  end
  puts "Done #{ii / name_to_donors.size.to_f * 100}"
end
# Donor.each do |donor|
#   donors = Donor.
#     where("id != ? AND LEVENSHTEIN(name, ?) < 4", donor.id, donor.name).
#     select(:id, :name, :country, Sequel.lit('LEVENSHTEIN(name, ?)', donor.name.gsub(/\'/, '')).as(:distance)).
#     order(Sequel.lit('LEVENSHTEIN(name, ?)', donor.name.gsub(/\'/, ''))).
#     limit(5)  
#   if donors.count != 0
#     donor_name = (donor.name.match(/[a-zA-Z]/) ? donor.name : donor.name.reverse )
#     puts "#{donor.id} => #{reverse_unless_english(donor.name)} from " + 
#       "#{reverse_unless_english(donor.country)}"
#     donors.each do |dc|      
#       puts "\t#{dc.id} => #{reverse_unless_english(dc.name)} from" + 
#         " #{reverse_unless_english(dc.country)}, #{dc[:distance]}"
#     end
#     STDIN.gets
#   end
# end