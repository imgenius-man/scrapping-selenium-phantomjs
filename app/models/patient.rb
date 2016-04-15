class Patient < ActiveRecord::Base
	require 'csv'
	require 'parsers/parse_container'

	extend PatientsHelper

	attr_accessible :record_available, :dob, :first_name, :last_name, :patient_id, :username, :password, :site_to_scrap, :token, :raw_html, :json, :site_url

	serialize :json, JSON

	def self.parse_subscriber_info(panel,driver)
		subscriber_info = []
		if panel.find_element(:class, 'patientAddress')
			address = panel.find_element(:class, 'patientAddress').text.split("\n")
			address_1 = address.first
			cit_st_zip = address.last.split(',')
			city = cit_st_zip.first
			state = cit_st_zip.last.strip.split(' ').first
			zip_code = cit_st_zip.last.strip.split(' ').last

			subscriber_info << {'ADDRESS 1'=>address_1,'City'=> city,'State'=> state,'Zip'=> zip_code}

		end
		# sub_info = panel.find_elements(:class, 'span6').last.text.split("\n")


		sub_info = panel.find_elements(:css, '.panel-body > div.span6 > ul > li')
		# sub_info = panel.find_elements(:css, '.panel-body > .span6')
		if sub_info!=nil

			# li = sub_info[0].find_elements(:tag_name, 'li')
			keys = ["PLAN NAME","PLAN NUMBER","RELATIONSHIP TO SUBSCRIBER","MEMBER ID","GROUP NUMBER","PLAN SPONSOR NAME","SUBSCRIBER"]
			li =sub_info

			li.each {|l|
				keys.each_with_index{|key,index|
					if l.text.include? key
						if key != "SUBSCRIBER"
							subscriber_info << {key => l.text.split(key).last.strip}
						elsif

							subscriber_name =  l.text.split(key).last.strip

							full_name = subscriber_name.split(',')
							last_name = full_name.first

							rest_name = full_name.last.split(' ')

							first_name = rest_name.first
							middle_name = rest_name.last if rest_name.count > 1
							subscriber_info << {"First Name" => first_name}
							subscriber_info << {"Last Name" => last_name}
							subscriber_info << {"Middle Name" => middle_name}

						end
					end
				}
			}

			# li = sub_info[1].find_elements(:tag_name, 'li')
			# keys = ["PLAN NUMBER","RELATIONSHIP TO SUBSCRIBER","MEMBER ID","GROUP NUMBER","PLAN SPONSOR NAME","SUBSCRIBER"]
			#
			# li.each {|l|
			# 	keys.each_with_index{|key,index|
			# 		if l.text.include? key
			# 			if key != "SUBSCRIBER"
			# 				subscriber_info << {key => l.text.split(key).last.strip}
			# 			elsif
			#
			# 				subscriber_name =  l.text.split(key).last.strip
			#
			# 				full_name = subscriber_name.split(',')
			# 				last_name = full_name.first
			#
			# 				rest_name = full_name.last.split(' ')
			#
			# 				first_name = rest_name.first
			# 				middle_name = rest_name.last if rest_name.count > 1
			# 				subscriber_info << {"First Name" => first_name}
			# 				subscriber_info << {"Last Name" => last_name}
			# 				subscriber_info << {"Middle Name" => middle_name}
			#
			# 			end
			# 		end
			# 	}
			# }

			# group_no = sub_info[0][0].split('GROUP NUMBER').last.strip
			# plan_sponsor_name = sub_info[1].split('PLAN SPONSOR NAME').last.strip
			#
			# relation = driver.find_element(:css, 'h4.condensed > small').text

		end

		 subscriber_info = subscriber_info.reduce({},:merge)

		# subscriber_info = {'Group No'=>group_no, 'Address 1'=>address_1, 'City'=>city, 'State'=>state, 'Zip'=>zip_code, 'Relationship to Subscriber'=>relation}

		subscriber_info= {'SUBSCRIBER'=>subscriber_info}

	end

	def self.parse_plan_info(panel,driver)
		plan_info = []
		li = panel.find_elements(:tag_name, 'li')

		keys = ["INSURANCE TYPE", "PLAN / PRODUCT"]

		li.each {|l|
			keys.each{|key|
				if l.text.include? key
					plan_info << {key => l.text.split(key).last.strip}
				end
			}
		}

		# plan_type = li[0].text.split('INSURANCE TYPE').last.strip
		# account_name = li[1].text.split('PLAN / PRODUCT').last.strip
		# plan_info = {'Plan Type'=>plan_type,'Account Name'=>account_name}

		plan_info = {"Plan Details"=>plan_info}
	end

	def self.parse_payer_info(panel,driver)

		payer_details = panel.find_elements(:class, 'span6')[2] if  panel.find_elements(:class, 'span6').count == 4
		ul = payer_details.find_elements(:tag_name,'ul')
		keys  = ["NAME","TYPE"]
		val_arr=[]
		payer_info = []

		 if ul.count>1
			 li = ul[1].find_elements(:tag_name,'li')
			 li.each {|l|
				 keys.each{|key|
					 if l.text.include? key
						 payer_info << {key => l.text.split(key).last.strip}
					 end
				 }
			 }
		 end

		 contact_info = panel.find_elements(:class, 'contact-information')
		 if !contact_info.empty?
			 payer_contact_name = contact_info.first.text.split("\n").first.strip
			 payer_contact_number = contact_info.first.text.split(':').last.strip
			#  payer_info << {'naem'=>payer_contact_name}
			#  payer_info << {'numb'=>payer_contact_number}
		 end


		 payer_info =payer_info.reduce({},:merge)
		 payer_info={'PAYeR'=>payer_info}


	end

	def self.parse_provider_info(panel,driver)
		provider_info = []
		p_detail = panel.find_elements(:class,'span6').last
		p_address = p_detail.find_elements(:tag_name, 'div').first
		if p_address != nil
			provider_address = p_address.text.split("\n")
			address_1 = provider_address[0]+" "+provider_address[1]

			cit_st_zip = provider_address[2].split(',')
			city = cit_st_zip[0]
			state = cit_st_zip[1].strip.split(' ').first
			zip_code = cit_st_zip[1].strip.split(' ').last

			provider_info << {'ADDRESS 1'=>address_1,'City'=> city,'State'=> state,'Zip'=> zip_code}

		end

		li = p_detail.find_elements(:tag_name, 'li')
		keys = ["NAME", "TYPE", "ROLE", "NPI" , "PLACE OF SERVICE"]
		# li = ul[1].find_elements(:tag_name,'li')

		li.each {|l|
			keys.each{|key|
				if l.text.include? key
					provider_info << {key => l.text.split(key).last.strip}
				end
			}
		}




		provider_info = provider_info.reduce({},:merge)
		# starter = 0
		# starter = 1 if provider_details.first.attribute('innerHTML').include? 'label'

		# spliting_array=["NAME", "TYPE", "ROLE", "NPI" , "PLACE OF SERVICE"]
		# val_arr = ["","","","","",""]



		# provider_details[starter..provider_details.length].map.with_index(starter) do |provider_detail,index|
		# 	val_arr[index] = provider_detail.text.split(spliting_array[index]).last.strip
		# end


		# spliting_array.delete_at(0) if starter == 1
		# val_arr.delete_at(0) if starter == 1

		# provider_info = { spliting_array[0]=> val_arr[0], spliting_array[1]=> val_arr[1], spliting_array[2]=> val_arr[2], spliting_array[3]=> val_arr[3], spliting_array[4]=> val_arr[4],spliting_array[5]=> val_arr[5],
		#  provider_info = { val_arr[0]=> spliting_array[0], val_arr[1] => spliting_array[1], val_arr[2]=> spliting_array[2], val_arr[3]=> spliting_array[3], spliting_array[4]=> val_arr[4],val_arr[5] => spliting_array[5],
			#  'ADDRESS 1'=>address_1,'City'=> city,'State'=> state,'Zip'=> zip_code}


		provider_info = {"PLAN PROVIDER"=>provider_info}
		# [provider_info,spliting_array,starter,val_arr]

	end

	def self.parse_general_info(driver)

	 transaction_details = driver.find_element(:css, '.inline')

	 li = transaction_details.find_elements(:tag_name, 'li')

	 trans_datetime = li[1].text.split('Date:').last.strip.split(' ')

	 transaction_date = trans_datetime[0]+' '+ trans_datetime[1]
	 transaction_time =  trans_datetime[2]+' '+ trans_datetime[3]

	 status_text = driver.find_element(:css,'div.panel-footer:nth-child(3)').text

	 status = nil
	 if status_text.include? 'Patient is Inactive'
		 status = 'Inactive'
	 else
		 status = 'Active'
	 end

	#  eligibility_as_of = driver.find_elements(:css,'.span8 > ul:nth-child(1) > li:nth-child(2)').first.text.split('DATE OF SERVICE').last.strip
	# 'ELIGIBILITY AS OF'=> eligibility_as_of ,
	 general_info = {'Eligibility Status'=>status ,'TRANSACTION DATE'=>transaction_date ,'TRANSACTION TIME'=>transaction_time	}
	 general_info = {'GENERAL'=>general_info}
	end


	def self.parse_patient_info(panel,driver)
	  patient_info = []
		# puts "1"
		panel_heading = panel.find_elements(:class => 'panel-heading')
		# puts "2"
	  patient_name_relation = panel_heading[0].find_element(:tag_name=> 'h4')
		# puts "3"
		relation = patient_name_relation.find_element(:tag_name, 'small').text
		# puts "4"
		patient_name = patient_name_relation.text.split(relation).first.strip
		# puts "5"
		full_name = patient_name.split(',')
		# puts "6"
		last_name = full_name.first
		# puts "7"
		rest_name = full_name.last.split(' ')
		# puts "8"

		first_name = rest_name.first
		# puts "9"
		middle_name = rest_name.last if rest_name.count > 1
		# puts "10"

	  li = panel_heading[0].find_elements(:class=> 'span4').first.find_elements(:tag_name, 'li')
		# puts "11"

	  # member_id = patient_info[0].text.split('MEMBER ID').last.strip
	  # dob = patient_info[1].text.split('DOB').last.strip
	  # gender = patient_info[2].text.split('GENDER').last.strip

		keys=["MEMBER ID","DOB","GENDER"]
		# puts "12"
		val_arr=[]
		# puts "13"
		li.each {|l|
			keys.each_with_index{|key,index|
				if l.text.include? key
					patient_info << {key => l.text.split(key).last.strip}
				end
			}
		}
		# puts "14"
		li = panel_heading[0].find_elements(:class=> 'span8').first.find_elements(:tag_name, 'li')
		# puts "15"
		keys=["PLAN / COVERAGE DATE","DATE OF SERVICE","ELIGIBILITY END DATE"]
		# puts "16"

		li.each {|l|
			keys.each_with_index{|key,index|
				if l.text.include? key
					patient_info << {key => l.text.split(key).last.strip}
				end
			}
		}
		# puts "17"
		patient_info = patient_info.reduce({},:merge)

	  # coverage_date = patient_info[0].text.split('PLAN / COVERAGE DATE').last.strip
	  # date_of_service = patient_info[1].text.split('DATE OF SERVICE').last.strip
	  # patient_info = {'First Name'=>first_name,'Middle Name'=>middle_name ,'Last Name'=>last_name,'Patient ID'=>member_id ,'DOB'=>dob,'Gender'=>gender }

		patient_info = { 'PATIENT'=>patient_info}
	end

	def self.av_code(driver)
		parse = ParseTable.new

    @json = []

    driver.find_elements(:css, '.service-types-container > .unstyled > li').each do |html|

      li_html = html.attribute('innerHTML')

      li_html

      table_array = parse.dummy_array_for_h2_table_availity()

      page = Mechanize::Page.new(nil,{'content-type'=>'text/html'},li_html,nil,Mechanize.new)

      header = page.at('h3').text.squish

      key = []

      page.search('.panel.panel-condensed').each do |sub_container|
        string = sub_container.at('h4').text.squish
        if string.scan('-').count == 1
          key[1] = string.split(/[-(]/).first # check this - there are more "-" in co=payment and co-insurence

        elsif string.scan('-').count > 1
          arr = string.split('-')
          arr[arr.length-1] = ''

          string = arr.inject(:+)

          key[1] = string.split('(').first # check this - there are more "-" in co=payment and co-insurence
        end

        data = sub_container.at('div').text.squish.split('Remaining')
        data_sv = sub_container.at('div').text.squish.split(/(In\s+|Out\s+)/).reject{|v| v == 'Out ' || v == 'In ' || v == ''}

        arr = []
        if data[0].scan('$').count == 3
          data.each do |row|
            row.strip!

            if row.scan('In Network').present?
              key[2] = 'In Network'

            elsif row.scan('Out Of Network').present?
              key[2] = 'Out Of Network'
            end

            if row.scan('Family').present?
              key[0] = 'Family'

            elsif row.scan('Individual').present?
              key[0] = 'Individual'
            end

            costs = row.split.reject{|a| a if !a.scan('$').present?}

            final_key_amount = key[0].to_s+key[1].to_s+'AMOUNT'+key[2].to_s
            arr << {final_key_amount.upcase.gsub(/[-\s+]/,'') => costs[0]}

            final_key_met = key[0].to_s+key[1].to_s+'MET'+key[2].to_s
            arr << {final_key_met.upcase.gsub(/[-\s+]/,'') => costs[1]}

            final_key_remaining = key[0].to_s+key[1].to_s+'Remaining'+key[2].to_s
            arr << {final_key_remaining.upcase.gsub(/[-\s+]/,'') => costs[2]}

          end

          arr = arr.reduce({},:merge)

          da = table_array.each do |k,v|
            table_array[k] = arr[k.upcase.gsub(/[-\s+]/,'')] if arr[k.upcase.gsub(/[-\s+]/,'')].present?
          end
        end

        if data_sv[0].scan(/[$%]/).count == 1
          data_sv.each do |row|
            puts row

            row.strip!

            if row.scan('Of Network').present?
              key[2] = 'Out Of Network'

            elsif row.scan('Network').present?
              key[2] = 'In Network'
            end

            if row.scan('Family').present?
              key[0] = 'Family'

            elsif row.scan('Individual').present?
              key[0] = 'Individual'
            end

            row = row.split

            costs = row.map.with_index(0) do |a, i|
              if a.scan('$').present?
                v = a
              elsif a.scan('%').present?
                v = row[i-1]+'%'
              end

              v
            end

            if key[1].upcase.gsub(/[-\s+]/,'') == 'COPAYMENT' && key[2].present?
              puts "==="*100
              puts "COPAY (TYPE)- #{key[2].to_s.upcase}"
              table_array["COPAY (TYPE)- #{key[2].to_s.upcase}"] = costs.reject(&:nil?).inject(:+)

            elsif key[1].upcase.gsub(/[-\s+]/,'') == 'COINSURANCE' && key[2].present?
              puts "==="*100
              puts "COINSURANCE (STANDARD)- #{key[2].to_s.upcase}"
              table_array["COINSURANCE (STANDARD)- #{key[2].to_s.upcase}"] = costs.reject(&:nil?).inject(:+)
            end
          end
        end
        puts table_array.inspect
      end

      table_array['CODE'] = header.split('-').last

      @json << { header.split('-').first.to_s => table_array }

    end
    puts @json.inspect


	end

	def self.my_program(patient_id,patient_dob)
		driver = availity(patient_id,patient_dob)
		if driver
			sleep(15)
			response_container = driver.find_element(:class=> 'response-container')
			panels = response_container.find_elements(:class => 'panel')
			data_arr = []

			data_arr << parse_general_info(driver)

			panels.each_with_index do |panel,index|
				heading = panel.find_elements(:class, 'panel-heading')
				if !heading.empty?
					heading = heading.first.text
				  if heading.downcase.tr(' ','') == "Subscriber Information".downcase.tr(' ','') || heading.downcase.squish.tr(' ','') == "Patient Information Subscriber Information".downcase.tr(' ','') ||  heading.downcase.tr(' ','') == "Patient Information".downcase.tr(' ','')
						puts "Going in Subscriber Deatil"
						data_arr <<  parse_subscriber_info(panel,driver)
						puts 'Subscriber Deatil'
				  elsif heading.downcase.tr(' ','').tr('/','') == "Plan / Product Information".downcase.tr(' ','').tr('/','')
						puts "Going in Plan Detail"
						data_arr <<  parse_plan_info(panel,driver)
						puts "Plan Detail"
				  elsif heading.downcase.squish.tr(' ','') == "Payer Details\nOther or Additional Payers".downcase.squish.tr(' ','')
						puts "Going in Payer Deatil"
						data_arr <<  parse_payer_info(panel,driver)
						puts 'Payer Deatil'
				  elsif heading.downcase.tr(' ','') == "Provider Details".downcase.tr(' ','')
						puts "Going in Provider Deatil"
						data_arr <<  parse_provider_info(panel,driver)
						puts 'Provider Deatil'
				  elsif index == 0
						puts "Going in Patient Deatil"
				    data_arr << parse_patient_info(panel,driver)
						puts 'Patient Detail'
				  end
				end
			end
		end
		data_arr
	end

	def self.availity(patient_id,patient_dob)
		driver = Selenium::WebDriver.for :firefox
		site_url =  'https://apps.availity.com/availity/web/public.elegant.login'
		driver.navigate.to site_url
		name = 'prospect99'
		pass = 'Medicare#20'
		username = driver.find_element(:name => 'userId')
		username.send_keys name
		password = driver.find_element(:name=> 'password')
		password.send_keys pass
		login_btn = driver.find_element(:id=> 'loginFormSubmit')
		login_btn.click
		sleep(5)
		# alert_btn = driver.find_element(:id=> 'alerts-continue')
		# alert_btn.click
		eligibility_url = "https://apps.availity.com/public/apps/eligibility/"
		driver.navigate.to eligibility_url
		sleep(30)
		a = driver.find_element(:css=> '.modal-header')
		a.find_element(:class=> 'close').click if a
		sleep(2)
		# org_drop_down
		driver.find_element(:css=> '#organizationDropDownSingle_chzn').click
		sleep(1)
		org_drop_down = driver.find_element(:css=> '#organizationDropDownSingle_chzn > div:nth-child(2) > div:nth-child(1) > input:nth-child(1)')
		sleep(1)
		org_drop_down.send_keys 'NORTHWEST'
		sleep(2)
		org_drop_down.send_keys:return
		sleep(6)
		a = driver.find_elements(:tag_name, 'input')
		payer_name = 'BCBSIL'
		sleep(3)
		drop_downs = driver.find_elements(:css=> 'div > div > a > span')
		drop_downs[0].click
		sleep(2)
		payer_div = driver.find_element(:css=> '.form-tight > div:nth-child(2)')
		payer_input = payer_div.find_element(:tag_name, 'input')
		payer_input.send_keys payer_name
		sleep(1)
		payer_input.send_keys:return
		sleep(4)
		provider_name = 'NORTHWEST MEDICAL CARE'
		drop_downs = driver.find_elements(:css=> 'div > div > a > span')
		drop_downs[1].click
		sleep(2)
		n = drop_downs[1].attribute('id').split('-').last
		provider_input = driver.find_element(:css=> "#s2id_autogen#{n}_search")
		sleep(1)
		provider_input.send_keys provider_name
		sleep(3)
		provider_input.send_keys:return
		sleep(5)
		drop_downs = driver.find_elements(:css=> 'div > div > a > span')
		drop_downs[3].click
		add_classes = driver.find_elements(:class=> 'chzn-results')[2].find_elements(:tag_name=> 'li')[1].attribute('id')
		number = add_classes.split('_')
		number[number.length-1] = '0'
		remove_classes = number.join('_')
		driver.execute_script("$('##{remove_classes}').removeClass('highlighted result-selected')")
		driver.execute_script("$('##{add_classes}').addClass('highlighted result-selected')")
		driver.find_element(:class=> 'highlighted').click
		place_service_val = 'Office'
		drop_downs = driver.find_elements(:css=> 'div > div > a > span')
		drop_downs[5].click
		sleep(1)
		place = driver.find_element(:css=> '.form-tight > div:nth-child(3) > div:nth-child(2) > div:nth-child(5)')
		sleep(1)
		place_input =place.find_element(:tag_name,'input')
		sleep(1)
		place_input.send_keys place_service_val
		sleep(1)
		place_input.send_keys:return
		benefit_val = 'Health Benefit'
		drop_downs = driver.find_elements(:css=> 'div > div > a > span')
		drop_downs[6].click
		benefit = driver.find_element(:css=> '.service-type-dropdowns')
		sleep(1)
		benefit_input = benefit.find_element(:tag_name,'input')
		sleep(1)
		benefit_input.send_keys benefit_val
		sleep(1)
		benefit_input.send_keys :return
		sleep(5)
		# patient_id = 'FBOXZ151779800'
		driver.find_element(:id=> 'memberIdInput').send_keys patient_id
		# patient_dob = "02/22/1957"
		driver.find_element(:css=> '.ng-valid-patient-birth-date').send_keys patient_dob
		submit_btn = driver.find_element(:css=> '#coverageFormSubmitButton')
		submit_btn.click
		driver
	end

	def self.clean(id)
		a=Patient.find(id)
		a.raw_html = nil
		a.json = nil
		a.record_available = "failed"
		a.save
	end

	def self.parse_containers(containers, date_of_eligibility, eligibility_status, transaction_date)
		@cont = ParseContainer.new.tabelizer(containers)

		@json = []

		@cont.each do |cont|
		  cont[1..cont.length].each do |con|
		   @json << ParseTable.new.json_table(con[:table], cont.first[:name], con[:header_count], con[:additional_info], cont.last[:info])
		  end
		end

		@json.reject!(&:nil?).reject!{|a| a == false}
    	@json = [{'General' => {'ELIGIBILITY AS OF' => date_of_eligibility, 'ELIGIBILITY STATUS' => eligibility_status, 'TRANSACTION DATE' => transaction_date}}] + @json

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
