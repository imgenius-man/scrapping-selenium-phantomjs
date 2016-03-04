class ChangeDobTypeOfUsers < ActiveRecord::Migration
  def change
  	change_column :users, :json, "json USING (dob::json)"
  end

  def down
  end
end
