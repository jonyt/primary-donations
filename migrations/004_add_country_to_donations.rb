Sequel.migration do
  change do
  	alter_table :donations do
        add_column :country, String
    end
  end
end