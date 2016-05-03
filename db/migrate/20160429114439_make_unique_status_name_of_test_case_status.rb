class MakeUniqueStatusNameOfTestCaseStatus < ActiveRecord::Migration
  def change
    add_index :test_case_statuses, :status_name, :unique => true
  end
end
