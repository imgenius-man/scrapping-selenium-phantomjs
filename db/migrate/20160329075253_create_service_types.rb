class CreateServiceTypes < ActiveRecord::Migration
  def change
    create_table :service_types do |t|

      t.string :type_name
      t.string :type_code
      
      t.timestamps
    end
  end
end
