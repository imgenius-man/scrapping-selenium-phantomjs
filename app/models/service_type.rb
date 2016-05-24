class ServiceType < ActiveRecord::Base
  # attr_accessor :type_code, :type_name
  belongs_to :status

  def self.to_csv(id)
   column_names="type_name","type_code"
   all_id = Status.find_by_site_url("all").id #mapped_service: true
   @service_types =  ServiceType.where(mapped_service: true) && ServiceType.where(status_id: id) if id != all_id
   @service_types = ServiceType.where(status_id: all_id) if id == all_id

   CSV.generate do |csv|
     csv << column_names
     @service_types.each do |stype|
       csv << stype.attributes.values_at(*column_names)
     end
   end
 end

end
