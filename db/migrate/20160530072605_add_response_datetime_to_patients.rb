class AddResponseDatetimeToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :response_datetime, :datetime
  end
end
