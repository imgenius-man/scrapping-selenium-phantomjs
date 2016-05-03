class CreateTestCaseStatuses < ActiveRecord::Migration
  def change
    create_table :test_case_statuses do |t|
      t.string :status_name
      t.boolean :status_result

      t.timestamps
    end
  end
end
