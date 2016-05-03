class AddTestStatusHashToStatuses < ActiveRecord::Migration
  def change
    add_column :statuses, :test_status_hash, :text
  end
end
