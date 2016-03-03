class AddRecordAvailableToUsers < ActiveRecord::Migration
  def change
    add_column :users, :record_available, :boolean, :default => false
  end
end
