class DeleteColumnsFromStatuses < ActiveRecord::Migration
  def change
    remove_column :statuses, :login_status
    remove_column :statuses, :patient_search_status
    remove_column :statuses, :site_status
    remove_column :statuses, :status
  end
end
