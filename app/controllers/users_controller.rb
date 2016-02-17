class UsersController < ApplicationController
  # require "watir-webdriver"
	def search_data
    begin
    	require "selenium-webdriver"
      if params[:user][:first_name].present? && params[:user][:last_name].present? && params[:user][:dob].present? && params[:user][:patient_id].present?
        wait = Selenium::WebDriver::Wait.new(timeout: 20)
        
        driver = Selenium::WebDriver.for :phantomjs, :args => ['--ignore-ssl-errors=true']
        # driver = Selenium::WebDriver.for :firefox
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

        member_id.send_keys params[:user][:patient_id]

        dob = driver.find_element(:name, 'memberDataList[0].dobDate')
        dob.send_keys params[:user][:dob]
        first_name = driver.find_element(:name, 'memberDataList[0].firstName')
        first_name.send_keys params[:user][:last_name]
        last_name = driver.find_element(:name, 'memberDataList[0].lastName')
        last_name.send_keys params[:user][:first_name]
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

          @table1 = tables[0].attribute('innerHTML').gsub("\t","").gsub("\n","")
          @table2 = tables[1].attribute('innerHTML').gsub("\t","").gsub("\n","")
          @table3 = tables[2].attribute('innerHTML').gsub("\t","").gsub("\n","")
          @table4 = tables[3].attribute('innerHTML').gsub("\t","").gsub("\n","")
          @table5 = tables[4].attribute('innerHTML').gsub("\t","").gsub("\n","")
          @table6 = tables[5].attribute('innerHTML').gsub("\t","").gsub("\n","")
        
          driver.quit
        else
          flash[:danger] = "Please enter correct information"
          redirect_to :back
        end
      else
        flash[:danger] = "All fields are required."
        redirect_to :back
      end
    rescue Exception=> e
      puts "77777"*90
      puts e.inspect
      flash[:info] = "Time Out. Please try again later."
      redirect_to :back
    end 
  end
end
