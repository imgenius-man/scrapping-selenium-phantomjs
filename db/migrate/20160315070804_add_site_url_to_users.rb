class AddSiteUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :site_url, :string
  end
end
