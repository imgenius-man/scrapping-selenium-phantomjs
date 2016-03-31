class AddRecordAvailableToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :record_available, :string
  end
end
