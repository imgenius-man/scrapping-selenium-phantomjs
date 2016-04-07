class Crawler < Struct.new(:f_name, :l_name, :date_of_birth, :pat_id, :patientid, :pass, :token, :patntid, :site_url, :response_url)


	def perform
     begin
      patient = Patient.find(patntid)

      obj = PatientsController.new.sign_in(patientid, pass, site_url)

      driver = obj[:driver]

      wait = obj[:wait]

      href_search = ''
      wait.until {
        href_search = driver.find_elements(:class,'patients')[1]
      }
      href_search.click

      member_id = nil
      wait.until {
        member_id = driver.find_element(:name, 'memberDataList[0].memberId')
      }

      member_id.send_keys pat_id

      dob = driver.find_element(:name, 'memberDataList[0].dobDate')
      dob.send_keys date_of_birth

      first_name = driver.find_element(:name, 'memberDataList[0].firstName')
      first_name.send_keys f_name

      last_name = driver.find_element(:name, 'memberDataList[0].lastName')
      last_name.send_keys l_name

      ee = driver.find_elements(:class,'btn-submit-form-patient-search')[0]
      ee.submit

      sleep(2)
      eee = driver.find_elements(:class,'btn-submit-form-patient-search')[0]
      if !eee.present?
        link = nil

        eligibility_status = driver.find_elements(:css,'.patient-search-result-table > tbody > tr > td')[7].attribute('innerHTML')
        
        transaction_date = Time.now.to_datetime.strftime("%d/%m/%y %H:%M %p")
        
        date_of_eligibility = driver.find_element(:css, '.patient-results-onDate > span').attribute('innerHTML')
        
        patient_flag = true

        wait.until {
          link = driver.find_elements(:css,'.patient-search-result-table > tbody > tr > td > .oep-managed-link')[0]
        }
        link.click

        patient_flag = false

        wait.until { driver.find_elements(:class, 'collapseTable').present? }

        sleep(2)

        if driver.find_elements( :class,"oep-managed-sub-tab").second.displayed?
          driver.find_elements( :class,"oep-managed-sub-tab").second.click
        end

        sleep(4)

        wait.until { driver.find_elements(:class, 'collapseTable').present? }


        containers = driver.find_elements(:class, 'collapseTable-container')

        patient.update_attribute('raw_html', driver.find_element(:class, 'collapseTable-container').attribute('innerHTML'))

        @json = Patient.parse_containers(containers, date_of_eligibility, eligibility_status, transaction_date)

        driver.quit

        service_types = Status.find_by_site_url('https://cignaforhcp.cigna.com/').service_types
				# kcount = 0
	        @json.each_with_index do |table_name, index|

	          service_types.each do |serv_type|

	            if @json[index][table_name.keys.first].present? && table_name.present? && serv_type.present? && serv_type.type_name.upcase.gsub(/[-\s+*]/, '') == table_name.keys.first.upcase.gsub(/[-\s+*]/, '').tr(',','')
	              serv_type.mapped_service=true
								# serv_type.save!

                @json[index][table_name.keys.first]['CODE'] = serv_type.type_code.to_s
              else @json[index].present? && @json[index].first[0].present?
								key = @json[index]
								a = nil
								a = Status.find_by_site_url('https://cignaforhcp.cigna.com/').service_types && ServiceType.find_by_type_name(key.first[0].tr(',',''))
								if !a.present?
									b = ServiceType.new
									b.status_id = Status.find_by_site_url("https://cignaforhcp.cigna.com/").id
									b.type_name = key.first[0].tr(',','')
									# puts "++"*83
									# puts b.type_name
									b.mapped_service = true
									b.save!
								end
	            end
	          end
					end
					# puts "-=-=="*82
					# puts kcount
				if service_types.count == 0
					@json.each do |key,val|
						if key.present? && key.first[0].present?
              a = nil
  						a = Status.find_by_site_url('https://cignaforhcp.cigna.com/').service_types && ServiceType.find_by_type_name(key.first[0].tr(',',''))
  						if !a.present?
  							# puts key.first[0]
  							b = ServiceType.new
  							b.status_id = Status.find_by_site_url("https://cignaforhcp.cigna.com/").id
  							b.type_name = key.first[0].tr(',','')
  							b.mapped_service = true
  							b.save!
  						end
            end
					end

				end



        patient.update_attribute('record_available', 'complete')

        patient.update_attribute('json', JSON.generate(@json))

        if response_url.present?
          response = RestClient.post response_url, {data: JSON.generate(@json), token: token}
        end
      else
        PatientMailer::exception_email("PatientID(#{patient.id}) ==> Please enter correct information \n WebSite = #{site_url}").deliver

        if response_url.present?
          response = RestClient.post response_url, {error: 'invalid patient', token: token}
        end

        driver.quit if driver.present?

        patient.update_attribute('record_available', 'failed')
      end

     rescue Exception=> e
      if patient_flag
        PatientMailer::exception_email("PatientID(#{patient.id}) ==> User Inactive \n WebSite = #{site_url}").deliver

        @json = [{'General' => {'ELIGIBILITY AS OF' => date_of_eligibility, 'ELIGIBILITY STATUS' => eligibility_status, 'TRANSACTION DATE' => transaction_date}}]
        
        if response_url.present?
          response = RestClient.post response_url, {data: JSON.generate(@json), token: token}
        end

        driver.quit if driver.present?

        patient.update_attribute('record_available', 'complete')
        
        patient.update_attribute('json', JSON.generate(@json))

      else
        patient.update_attribute('record_available', 'failed')


        PatientMailer::exception_email("PatientID(#{patient.try(:id)}) ==> #{e.inspect} \n WebSite = #{site_url}").deliver

        driver.quit if driver.present?

        if response_url.present?
          response = RestClient.post response_url, {error: 'please try again', token: token}
        end
      end
     end
  end
end
