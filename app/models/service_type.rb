class ServiceType < ActiveRecord::Base
  attr_accessible :type_code, :type_name
  belongs_to :status

  def self.to_csv(id)
   column_names="type_name","type_code"
   @service_types =  Status.find(id).service_types
   CSV.generate do |csv|
     csv << column_names
     @service_types.each do |stype|
       csv << stype.attributes.values_at(*column_names)
     end
   end
 end

end
