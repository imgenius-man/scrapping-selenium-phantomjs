class AddStatusRefToServiceTypes < ActiveRecord::Migration
  def change
    add_column :service_types, :status_id, :integer
  end
end
