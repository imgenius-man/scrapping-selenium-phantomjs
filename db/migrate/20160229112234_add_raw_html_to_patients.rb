class AddRawHtmlToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :raw_html, :text
  end
end
