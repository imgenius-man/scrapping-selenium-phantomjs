class AddSiteIdToTestCaseStatuses < ActiveRecord::Migration
  def change
    add_column :test_case_statuses, :site_id, :integer, references: :statuses
  
  end
end
