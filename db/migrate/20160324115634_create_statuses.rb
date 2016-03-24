class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :site_url
      t.boolean :status
      t.datetime :date_checked

      t.timestamps
    end
  end
end
