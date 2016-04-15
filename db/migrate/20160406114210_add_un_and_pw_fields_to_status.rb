class AddUnAndPwFieldsToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :site_username, :string
    add_column :statuses, :site_password, :string
  end
end
