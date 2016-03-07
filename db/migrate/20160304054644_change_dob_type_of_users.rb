class ChangeDobTypeOfUsers < ActiveRecord::Migration
  def change
  	change_column :users, :json, :text
  end

  def down
  end
end
