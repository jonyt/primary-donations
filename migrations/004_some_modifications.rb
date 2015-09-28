Sequel.migration do
  change do
  	alter_table :parties do
        add_column :web_id, Integer
    end

    alter_table(:candidates) do
  	  drop_constraint(:candidates_name_key)
  	end

    alter_table(:donors) do
      add_column :country, String
    end

    alter_table(:donations) do
      set_column_default :currency, 'nis'
    end

    DB.run('UPDATE parties SET web_id = 13 WHERE id = 4')
  end
end