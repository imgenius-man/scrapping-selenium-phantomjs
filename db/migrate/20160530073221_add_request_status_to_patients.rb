class AddRequestStatusToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :request_status, :string
  end
end
