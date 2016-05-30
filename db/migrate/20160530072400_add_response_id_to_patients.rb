class AddResponseIdToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :response_id, :string
  end
end
