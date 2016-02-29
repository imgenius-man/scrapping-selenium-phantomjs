class AddRawHtmlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :raw_html, :text
  end
end
