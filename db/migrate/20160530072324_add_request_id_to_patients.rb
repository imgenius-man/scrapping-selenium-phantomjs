class AddRequestIdToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :request_id, :string
  end
end
