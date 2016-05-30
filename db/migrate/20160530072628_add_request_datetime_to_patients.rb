class AddRequestDatetimeToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :request_datetime, :datetime
  end
end
