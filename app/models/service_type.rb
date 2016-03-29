class ServiceType < ActiveRecord::Base
  attr_accessible :type_code, :type_name

  def self.to_csv
   column_names="type_name","type_code"
   CSV.generate do |csv|
     csv << column_names
     all.each do |product|
       csv << product.attributes.values_at(*column_names)
     end
   end
 end

end
