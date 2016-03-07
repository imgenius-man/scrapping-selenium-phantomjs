class User < ActiveRecord::Base
	require 'csv'
	require 'parsers/parse_container'


	attr_accessible :record_available, :dob, :first_name, :last_name, :patient_id, :username, :password, :site_to_scrap, :token, :raw_html, :json 

	serialize :json, JSON

	def self.parse_containers(containers, date_of_eligibility)
		@cont = ParseContainer.new.tabelizer(containers)
	
		@json = []

		@cont.each do |cont|
		  cont[1..cont.length].each do |con| 
		   @json << ParseTable.new.json_table(con[:table], cont.first[:name], con[:header_count], con[:additional_info], cont.last[:info])
		  end
		end

		@json.reject!(&:nil?).reject!{|a| a == false}
    @json = [{'General' => {'ELIGIBILITY AS OF' => date_of_eligibility}}] + @json
		

		@json
	end
	

	def self.import(file)
      CSV.foreach(file.path, headers: true) do |row|
      user_hash = row.to_hash
      str = row.to_s.split(',')

      a= User.find_by_patient_id(str[3])
      if a
        a.update_attributes(first_name: str[0],last_name: str[1],dob: str[2],patient_id: str[3])
      else
        a=User.new
        a.first_name = str[0].squish
        a.last_name = str[1].squish
        a.dob = str[2].squish
        a.patient_id = str[3].squish
        a.save!
      end
    end
  end
	
end


				# next if td[:td].inject(&:+).present? && td[:td].inject(&:+) == "--"

