require 'sequel'
require 'io/console'

DB = Sequel.connect('postgres://yoni:telaviv@localhost:5432/primary_donations')
require_relative '../models/candidate'

unless ARGV.size == 2
  puts "Usage: #{$0} file party_id"
  exit
end
num_lines = `wc -l "#{ARGV[0]}"`.strip.split(' ')[0].to_f - 1
party_id = Integer(ARGV[1])
candidate_data = []
File.open(ARGV[0]).each do |line|
  next if $. == 1 || line.match(/^\s*$/)
  url, name = line.split(', ').map{|e| e.chomp}
  candidates = Candidate.
    where(party_id: party_id).
    order(Sequel.lit("LEVENSHTEIN(name, '#{name.gsub(/\'/, '')}')")).
    limit(4).to_a
  candidates << Candidate.new(name: 'enon', party_id: party_id)  
  puts "#{name.reverse} #{sprintf('%.1f', ($. - 1) / num_lines * 100)}"
  candidates.each_with_index do |candidate, index|
    puts "#{index}. #{candidate.name.reverse}"  
  end
  selection = STDIN.getch.to_i
  raise "Invalid choice #{selection}" unless (0..4).include?(selection)
  candidate_data << [url, candidates[selection].id]
  puts "#{name.reverse} -> #{candidates[selection].name.reverse}"
  puts "********************"
end

File.open(ARGV[0].sub('.txt', '_candidate_urls.txt'), 'w') do |file|
  candidate_data.each do |data|
    file.puts "#{data[0]}, #{data[1]}"
  end
end