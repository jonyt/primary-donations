# Run with sequel -m path/to/migration_dir mysql://yoni:telaviv@localhost/social_coupons_dev
# Foreign key constraints should be added (currently not working, because table is MyISAM, should be InnoDB)
Sequel.migration do
  change do

    create_table(:parties) do
      primary_key :id
      String :name, :null => false, :unique => true
    end  
    
    create_table(:candidates) do
      primary_key :id
      foreign_key(:party_id, :parties, :key => :id, :on_delete => :cascade, :null => false) 
      String :name, :null => false, :unique => true
    end

    create_table(:donors) do
      primary_key :id
      String :name, :null => false, :unique => true
    end

    create_table(:donations) do
      primary_key :id
      foreign_key(:candidate_id, :candidates, :key => :id, :on_delete => :cascade, :null => false)
      foreign_key(:donor_id, :donors, :key => :id, :on_delete => :cascade, :null => false) 
      Integer :amount, :null => false
      String :currency, :null => false
    end

  end

end