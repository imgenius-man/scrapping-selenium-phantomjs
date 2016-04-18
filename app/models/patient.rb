class Patient < ActiveRecord::Base
	require 'csv'
	require 'parsers/parse_container'
	require 'parsers/parse_availity'

	extend PatientsHelper

	attr_accessible :record_available, :dob, :first_name, :last_name, :patient_id, :username, :password, :site_to_scrap, :token, :raw_html, :json, :site_url

	serialize :json, JSON


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

	# def self.availity(patient_id,patient_dob)
	# 	driver = Selenium::WebDriver.for :firefox
	# 	site_url =  'https://apps.availity.com/availity/web/public.elegant.login'
	# 	driver.navigate.to site_url
	# 	name = 'prospect99'
	# 	pass = 'Medicare#20'
	# 	username = driver.find_element(:name => 'userId')
	# 	username.send_keys name
	# 	password = driver.find_element(:name=> 'password')
	# 	password.send_keys pass
	# 	login_btn = driver.find_element(:id=> 'loginFormSubmit')
	# 	login_btn.click
	# 	sleep(5)
	# 	alert_btn = driver.find_element(:id=> 'alerts-continue')
	# 	alert_btn.click
	def self.search_patient_availity(patient_id,patient_dob)
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

	def self.parse_availity_panels(driver,panels)
		josn = ParseAvaility.new.parse_panels(driver,panels)
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
		elsif site_url == options[2][1]
			fields = {user_field: 'userId', pass_field: 'password', submit_button: '#loginFormSubmit', error_string: 'login-failed'}
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
