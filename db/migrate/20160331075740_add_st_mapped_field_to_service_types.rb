class AddStMappedFieldToServiceTypes < ActiveRecord::Migration
  def change
    add_column :service_types, :mapped_service, :boolean
  end
end
