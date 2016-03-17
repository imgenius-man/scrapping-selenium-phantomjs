class User < ActiveRecord::Base
	require 'csv'
	require 'parsers/parse_container'

	extend UsersHelper

	attr_accessible :record_available, :dob, :first_name, :last_name, :patient_id, :username, :password, :site_to_scrap, :token, :raw_html, :json, :site_url

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
	

	def self.retrieve_signin_fields(site_url)
		options = User.options_for_site

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

      a= User.find_by_patient_id(str[3])
      if a
        a.update_attributes(first_name: str[0],last_name: str[1],dob: str[2],patient_id: str[3])
      else
        a=User.new
        a.first_name = str[0].squish if str[0]
        a.last_name = str[1].squish if str[1]
        a.dob = str[2].squish if str[2]
        a.patient_id = str[3].squish if str[3]
        a.save!
      end
    end
  end
	
end


				# next if td[:td].inject(&:+).present? && td[:td].inject(&:+) == "--"

# curl --data 'user[token]=x9.xYXVEUy/eaatFmNwiLqzYoEbmYGtu+&user[first_name]=PARUL&user[last_name]=PATEL&user[dob]=15/06/1986&user[patient_id]=U5151043002&user[username]=skedia105&user[password]=Empclaims100&user[site_url]=https://cignaforhcp.cigna.com/web/secure/chcp/windowmanager#tab-hcp.pg.patientsearch$1' http://gooper-dashboard.statpaymd.com/users/authenticate_token

# curl --data 'user[first_name]=PARUL&user[last_name]=PATEL&user[dob]=15/06/1986&user[patient_id]=U5151043002&user[username]=skedia105&user[password]=Empclaims100&user[site_url]=https://cignaforhcp.cigna.com/web/secure/chcp/windowmanager#tab-hcp.pg.patientsearch$1' http://gooper-dashboard.statpaymd.com/users/access_token