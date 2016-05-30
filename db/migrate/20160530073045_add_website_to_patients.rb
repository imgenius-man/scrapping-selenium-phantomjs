class AddWebsiteToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :website, :string
  end
end
