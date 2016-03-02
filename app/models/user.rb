class User < ActiveRecord::Base
	require 'csv'
	require 'parsers/parse_container'


	attr_accessible :dob, :first_name, :last_name, :patient_id, :username, :password, :site_to_scrap, :token, :raw_html, :json 

	def self.parse_containers(containers, date_of_eligibility)
		@cont = ParseContainer.new.parse_all(containers)
	
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
	

	
end


				# next if td[:td].inject(&:+).present? && td[:td].inject(&:+) == "--"

