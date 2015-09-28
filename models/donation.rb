require 'sequel'

class Donation < Sequel::Model	  
  many_to_one :donor
  many_to_one :candidate

  def from_params(params)
    self.amount = params['GD_Sum'].to_i
    self.date   = Time.at(params['GD_Date'].gsub(/\D/, '').to_i / 1000).to_date 
    self
  end  
end