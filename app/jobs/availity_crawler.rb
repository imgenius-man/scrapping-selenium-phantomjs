class AvailityCrawler < Struct.new(:pat_id,:patient_id,:patient_dob,:username,:pass,:site_url,:name_of_organiztion,:payer_name,:provider_name,:place_service_val,:benefit_val)

	def perform
		patient = Patient.find(pat_id)

		obj = PatientsController.new.sign_in(username, pass, site_url)


		driver = obj[:driver]

		wait = obj[:wait]


		if driver
			# search patient record
			sleep(15)
			eligibility_url = "https://apps.availity.com/public/apps/eligibility/"
			driver.navigate.to eligibility_url
			sleep(30)
			# wait.until { driver.find_element(:css=> '.modal-header').displayed? }
			a = driver.find_element(:css=> '.modal-header')
			a.find_element(:class=> 'close').click if a
			sleep(2)
			# org_drop_down
			driver.find_element(:css=> '#organizationDropDownSingle_chzn').click
			sleep(1)
			org_drop_down = driver.find_element(:css=> '#organizationDropDownSingle_chzn > div:nth-child(2) > div:nth-child(1) > input:nth-child(1)')
			sleep(1)
			name_of_organiztion = 'NORTHWEST MEDICAL CARE' if name_of_organiztion.nil?
			org_drop_down.send_keys name_of_organiztion
			sleep(2)
			org_drop_down.send_keys:return
			sleep(6)
			a = driver.find_elements(:tag_name, 'input')
			payer_name = 'BCBSIL' if payer_name.nil?
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
			provider_name = 'NORTHWEST MEDICAL CARE' if provider_name.nil?
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
			place_service_val = 'Office' if place_service_val.nil?
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
			benefit_val = 'Health Benefit'if benefit_val.nil?
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

			# ended searching patient





			sleep(30)
			response_container = driver.find_element(:class=> 'response-container')
			panels = response_container.find_elements(:class => 'panel')

			@json_arr = []
			@json_arr = Patient.parse_availity_panels(driver,panels)

      		patient.update_attribute('json', JSON.generate(@json_arr))
      		patient.update_attribute('record_available', 'complete')
			
			# @json_arr <<


		end
		# data_arr
  end
end
