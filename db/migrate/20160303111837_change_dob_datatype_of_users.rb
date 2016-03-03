class ChangeDobDatatypeOfUsers < ActiveRecord::Migration
  def change
  	change_column :users, :dob, :string
  end

  def down
  end
end
