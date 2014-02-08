require 'sinatra'
#require 'sequel'
#require 'json'

class App < Sinatra::Base

	get '/' do
		"hi"
	end
=begin
	db_url = (production? ? ENV['DATABASE_URL'] : 'postgres://yoni:telaviv@localhost/knesset_donations')

	configure do
	  puts "*************** #{db_url}"	
	  Sequel::Model.db = Sequel.connect db_url
	  require './models/donor'
	  require './models/donation'
	end

	helpers do
		def get_donations(donor_id)
			dataset = Donation.
				graph(:donors, :id => :donor_id).
				graph(:candidates, :id => :donations__candidate_id).
				graph(:parties, :id => :party_id).
				where(:donor_id => donor_id)
			results = dataset.inject([]) do |mem, item|
				currency = (item[:currency] == 'usd' ? '$' : '&#8362;')
				mem << [item[:name], item[:parties_name], item[:candidates_name], currency + item[:amount].to_s, item[:date]]
			end	

			results
		end
	end

	get '/' do
	  puts "*** index"	
	  "hi"
	 #  begin
	 #  	@donors = Donor.all.
		#   	inject([]){|mem, donor| mem << {:value => donor.id, :label => donor.name}}.
		#   	to_json
		# erb :index		
  # 	  rescue Exception => e
  # 		halt 500
  # 	  end		  
	end

	get '/donor/:id' do
		@donations = get_donations(params[:id])

		erb :donations
	end
=end	
end