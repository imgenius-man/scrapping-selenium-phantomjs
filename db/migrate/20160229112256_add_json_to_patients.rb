class AddJsonToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :json, :text
  end
end
