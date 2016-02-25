class AddUnPwToUsers < ActiveRecord::Migration
  def change
  	add_column :users, :site_to_scrap, :string
    add_column :users, :password, :string
	add_column :users, :username, :string

  end
end
