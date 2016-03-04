class ChangeRecordAvailableTypeOfUsers < ActiveRecord::Migration
  def change
  	change_column :users, :record_available, :string
  end

  def down
  end
end
