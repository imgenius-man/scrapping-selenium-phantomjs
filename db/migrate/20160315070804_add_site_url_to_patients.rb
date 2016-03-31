class AddSiteUrlToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :site_url, :string
  end
end
