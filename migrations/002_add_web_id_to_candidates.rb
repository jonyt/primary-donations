Sequel.migration do
  change do
  	alter_table :candidates do
        add_column :web_id, Integer
    end
  end
end