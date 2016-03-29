class Crawler < Struct.new(:f_name, :l_name, :date_of_birth, :pat_id, :userid, :pass, :token, :usrid, :site_url, :response_url)
	

	def perform
    begin
      user = User.find(usrid) 
      
      obj = UsersController.new.sign_in(userid, pass, site_url)
    
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
        wait.until {
          link = driver.find_elements(:css,'.patient-search-result-table > tbody > tr > td > .oep-managed-link')[0]
        }
        link.click

        wait.until { driver.find_elements(:class, 'collapseTable').present? }

        sleep(2)

        if driver.find_elements( :class,"oep-managed-sub-tab").second.displayed?
          driver.find_elements( :class,"oep-managed-sub-tab").second.click
        end

        sleep(4)

        wait.until { driver.find_elements(:class, 'collapseTable').present? }

        date_of_eligibility = driver.find_element(:css, '.patient-results-onDate > span').attribute('innerHTML')
        
        containers = driver.find_elements(:class, 'collapseTable-container')

        user.update_attribute('raw_html', driver.find_element(:class, 'collapseTable-container').attribute('innerHTML'))

        @json = User.parse_containers(containers, date_of_eligibility)

        if @json
          user.update_attribute('record_available', 'complete')
        end

        driver.quit

        service_types = ServiceType.all
        
        @json.each_with_index do |(table_name, table_content), index|
          service_types.each do |serv_type|
            
            if  serv_type.type_name.upcase.gsub(/[-\s+*]/, '') == table_name.keys.first.upcase.gsub(/[-\s+*]/, '')
              puts "---"*100
              puts index
              puts table_name.keys.first

              @json[index][@json[index].keys.first]['CODE'] = serv_type.type_code
              puts @json[index]
            end
          end
        end

        user.update_attribute('json', JSON.generate(@json))
        
        if response_url.present?
          response = RestClient.post response_url, {data: JSON.generate(@json), token: token}
        end
      else
        UserMailer::exception_email("UserID(#{user.id}) ==> Please enter correct information \n WebSite = #{site_url}").deliver
        
        if response_url.present?
          response = RestClient.post response_url, {error: 'invalid user', token: token}
        end

        driver.quit if driver.present?
        
        user.update_attribute('record_available', 'failed')
      end
    
    rescue Exception=> e
      user.update_attribute('record_available', 'failed')
      
      
      UserMailer::exception_email("UserID(#{user.try(:id)}) ==> #{e.inspect} \n WebSite = #{site_url}").deliver
      
      driver.quit if driver.present?
      
      if response_url.present?
        response = RestClient.post response_url, {error: 'please try again', token: token}
      end
    end 
  end
end