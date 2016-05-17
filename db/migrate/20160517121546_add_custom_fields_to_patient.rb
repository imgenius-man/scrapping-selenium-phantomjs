class AddCustomFieldsToPatient < ActiveRecord::Migration
  def change
    add_column :patients, :state_field, :string
    add_column :patients, :practice_name, :string
    add_column :patients, :payer_name, :string
    add_column :patients, :provider_name, :string
    add_column :patients, :provider_type, :string
    add_column :patients, :place_of_service, :string
    add_column :patients, :service_type, :string
  end
end
