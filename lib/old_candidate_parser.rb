require 'nokogiri'
require 'open-uri'

class RawDonation < Struct.new(:donor, :address, :date, :shekels, :other_currency)
end

class OldCandidateParser
  def initialize(url)
    @doc = Nokogiri::HTML(open(url))  
    raise Net::ReadTimeout if @doc.text.size < 100  
  end

  def candidate_name
    @doc.at_css('#ctl00_TdCandidateId').text
  end

  def donations
    rows = @doc.css('#ctl00_ContentPlaceHolder1_TableView > tr')
    rows.drop(2).inject([]) do |mem, row|
      data = row.>('td').map{|td| td.text}
      mem << RawDonation.new(
        data[3], 
        data[4], 
        Date.parse(data[0]), 
        data[1].gsub(',', '').to_f, 
        data[2].gsub(',', '').to_f
      )
    end    
  end
end

# p = OldCandidateParser.new('https://web.archive.org/web/20140803081026/http://primaries.publish.mevaker.gov.il/Donations.aspx?CandidateId=243&PartyId=2')
# puts p.candidate_name