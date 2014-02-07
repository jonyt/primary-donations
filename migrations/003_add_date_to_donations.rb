Sequel.migration do
  change do
  	alter_table :donations do
        add_column :date, DateTime
    end
  end
end