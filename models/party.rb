require 'sequel'

class Party < Sequel::Model	
  one_to_many :candidates
  # attr_reader :name#, :candidates

  # def initialize(web_id, name)
  #   @web_id = web_id
  #   @name = name
    # @candidates = []
  # end

  # def <<(candidate)
  #   @candidates << candidate
  # end

  def to_params
    {body: {action: 'gcbp', p: web_id}}
  end
end