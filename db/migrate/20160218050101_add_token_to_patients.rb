class AddTokenToPatients < ActiveRecord::Migration
  def change
    add_column :patients, :token, :string
  end
end
