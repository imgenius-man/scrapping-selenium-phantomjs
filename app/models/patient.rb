class Patient < ActiveRecord::Base
	require 'csv'
	require 'parsers/parse_container'

	extend PatientsHelper

	attr_accessible :record_available, :dob, :first_name, :last_name, :patient_id, :username, :password, :site_to_scrap, :token, :raw_html, :json, :site_url

	serialize :json, JSON

	def self.clean(id)
		a=Patient.find(id)
		a.raw_html = nil
		a.json = nil
		a.record_available = "failed"
		a.save
	end

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


	def self.retrieve_signin_fields(site_url)
		options = Patient.options_for_site

		if site_url == options[0][1]
			fields = {user_field: 'username', pass_field: 'password', submit_button: '#button1', error_string: 'error'}

		elsif site_url == options[1][1]
			fields = {user_field: 'portletInstance_6{actionForm.userId}', pass_field: 'portletInstance_6{actionForm.password}', submit_button: '.button_submit', error_string: 'login'}
		end

		fields
	end


	def self.import(file)
      CSV.foreach(file.path, headers: true) do |row|
      user_hash = row.to_hash
      str = row.to_s.split(',')

      a= Patient.find_by_patient_id(str[3])
      if a
        a.update_attributes(first_name: str[0],last_name: str[1],dob: str[2],patient_id: str[3])
      else
        a=Patient.new
        a.first_name = str[0].squish if str[0]
        a.last_name = str[1].squish if str[1]
        a.dob = str[2].squish if str[2]
        a.patient_id = str[3].squish if str[3]
        a.save!
      end
    end
  end

  def self.import_mapping(file,id)
 		obj = Status.find(id).service_types
		ServiceType.where(status_id: id).destroy_all

		CSV.foreach(file.path, headers: true) do |row|
			user_hash = row.to_hash
			str = row.to_s.split(',')

		if row.to_s.scan(/,/).count > 1
			new_str=[]
			new_str[0]=""
			str[0..str.count-2].each {|d|
				new_str[0] = new_str[0] + d + " "
			}
			new_str[1] = str[str.count-1].strip
			str = new_str
		end

				obj.create(type_name: (str[0].squish if str[0].present?), type_code: (str[1].squish if str[1].present?))

		end
	end

end
