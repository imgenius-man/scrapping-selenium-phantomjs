class Crawler < Struct.new(:f_name, :l_name, :date_of_birth, :pat_id)
	

	def perform
    begin
        wait = Selenium::WebDriver::Wait.new(timeout: 20)
        
        driver = Selenium::WebDriver.for :firefox
        # , :args => ['--ignore-ssl-errors=true']
        
        driver.navigate.to "https://cignaforhcp.cigna.com/web/secure/chcp/windowmanager#tab-hcp.pg.patientsearch$1"
        
        username = driver.find_element(:name, 'username')
        username.send_keys "skedia105"

        password = driver.find_element(:name, 'password')
        password.send_keys "Empclaims100"

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

        member_id.send_keys pat_id.to_s

        dob = driver.find_element(:name, 'memberDataList[0].dobDate')
        dob.send_keys date_of_birth
        
        first_name = driver.find_element(:name, 'memberDataList[0].firstName')
        first_name.send_keys l_name
        
        last_name = driver.find_element(:name, 'memberDataList[0].lastName')
        last_name.send_keys f_name
        
        ee = driver.find_elements(:class,'btn-submit-form-patient-search')[0]
        ee.submit

        sleep(2)
        
        eee = driver.find_elements(:class,'btn-submit-form-patient-search')[0]
        
        if !eee.present?
          link = nil
          wait.until {
            link = driver.find_elements(:class,'oep-managed-link')[5]
          }
          link.click

          wait.until { driver.find_elements(:class, 'collapseTable').present? }

          tables = driver.find_elements(:class, 'collapseTable')

          sanit = ActionView::Base
          
          @table1 = sanit.full_sanitizer.sanitize(tables[0].attribute('innerHTML'))
          @table2 = sanit.full_sanitizer.sanitize(tables[1].attribute('innerHTML'))
          @table3 = sanit.full_sanitizer.sanitize(tables[2].attribute('innerHTML').gsub("\t","").gsub("\n",""))
          @table4 = sanit.full_sanitizer.sanitize(tables[3].attribute('innerHTML').gsub("\t","").gsub("\n",""))
          @table5 = sanit.full_sanitizer.sanitize(tables[4].attribute('innerHTML').gsub("\t","").gsub("\n",""))
          @table6 = sanit.full_sanitizer.sanitize(tables[5].attribute('innerHTML').gsub("\t","").gsub("\n",""))
        
          driver.quit
      
      else
      	puts "(=All fields are required.=)"*90
      end
    
    rescue Exception=> e
      puts "77777"*90
      puts e.inspect
      
      puts "(=Time Out. Please try again later.=)"*90
    end 
  end
end