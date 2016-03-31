class AddUnPwToPatients < ActiveRecord::Migration
  def change
  	add_column :patients, :site_to_scrap, :string
    add_column :patients, :password, :string
	add_column :patients, :username, :string

  end
end
