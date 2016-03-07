class Crawler < Struct.new(:f_name, :l_name, :date_of_birth, :pat_id, :userid, :pass, :token, :usrid)
	

	def perform
    begin
      user = User.find(usrid) 

      wait = Selenium::WebDriver::Wait.new(timeout: 20)
        
      driver = Selenium::WebDriver.for :phantomjs, :args => ['--ignore-ssl-errors=true']
      # collapseTable-container
      driver.navigate.to "https://cignaforhcp.cigna.com/web/secure/chcp/windowmanager#tab-hcp.pg.patientsearch$1"
      
      username = driver.find_element(:name, 'username')
      username.send_keys userid

      password = driver.find_element(:name, 'password')
      password.send_keys pass

      element = driver.find_element(:id, 'button1')
      element.submit
      
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

        wait.until { driver.find_elements(:class, 'collapseTable').displayed? }

        if driver.find_elements( :class,"oep-managed-sub-tab").second.displayed?
          driver.find_elements( :class,"oep-managed-sub-tab").second.click
        end

        sleep(4)

        wait.until { driver.find_elements(:class, 'collapseTable').displayed? }

        date_of_eligibility = driver.find_element(:css, '.patient-results-onDate > span').attribute('innerHTML')
        
        containers = driver.find_elements(:class, 'collapseTable-container')

        user.update_attribute('raw_html', driver.find_element(:class, 'collapseTable-container').attribute('innerHTML'))

        @json = User.parse_containers(containers, date_of_eligibility)

        if @json
          user.update_attribute('record_available', 'complete')
        end

        driver.quit

        user.update_attribute('json', JSON.generate(@json))
      
      else
        puts "(=Please enter correct information)"*90
        
      end
    
    rescue Exception=> e
      user.update_attribute('record_available', 'failed')
      puts "77777"*90
      puts user.inspect
      driver.quit if driver.present?
      puts e.inspect
      
      puts "(=Time Out. Please try again later.=)"*90
    end 
  end
end