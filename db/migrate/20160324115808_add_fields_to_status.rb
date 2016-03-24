class AddFieldsToStatus < ActiveRecord::Migration
  def change
    add_column :statuses, :login_status, :boolean, :default => false
    add_column :statuses, :patient_search_status, :boolean, :default => false
    add_column :statuses, :site_status, :boolean, :default => false
  end
end
