class UsersController < ApplicationController

	
  def access_token
    if params[:user].present? && params[:user][:first_name].present? && params[:user][:last_name].present? && params[:user][:dob].present? && params[:user][:patient_id].present? && params[:user][:password].present? && params[:user][:username].present?        
      token = SecureRandom.base64(24)
      
      params[:user].merge!({token: token})
      
      created = User.create(params[:user])
      
      if created
        result = params[:user]

        Delayed::Job.enqueue Crawler.new(result[:first_name], result[:last_name], result[:dob], result[:patient_id], result[:username], result[:password], token)
      end
    
    else
      result = 'Not permitted'
    end
    
    render json: result
  end
  

  def create
    driver = signin_cigna(params[:user][:username], params[:user][:password], params[:user][:site_to_scrap])
    
    if driver.current_url.split("/").last.include?('error')
      flash[:danger] = "Please enter correct information"
    end

    driver.quit
    redirect_to :back 
  end


  def import
    User.import(params[:file])
    redirect_to root_url, notice: "Users imported."
  end


  def update
    user=User.find(params[:id])
    if user.json.present?
      show(user.id)
    else
      search_data(user)
    end
  end

  
  def show(id)
    user=User.find(id)
    @json=user.json.to_json
    render "search_data"
  end

  def signin_cigna(username, pass, site_url)
    wait = Selenium::WebDriver::Wait.new(timeout: 20)
    
    driver = Selenium::WebDriver.for :firefox #, :args => ['--ignore-ssl-errors=true']
    
    driver.navigate.to "https://cignaforhcp.cigna.com/web/secure/chcp/windowmanager#tab-hcp.pg.patientsearch$1"
    
    username = driver.find_element(:name, 'username')
    username.send_keys username

    password = driver.find_element(:name, 'password')
    password.send_keys pass

    element = driver.find_element(:id, 'button1')
    element.submit

    driver
  end


  def search_data(user)
    begin
      if user.first_name.present? && user.last_name.present? && user.dob.present? && user.patient_id.present?        
        wait = Selenium::WebDriver::Wait.new(timeout: 20)
        
        driver = Selenium::WebDriver.for :firefox 
        # , :args => ['--ignore-ssl-errors=true']
        # collapseTable-container
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

        member_id.send_keys user.patient_id

        dob = driver.find_element(:name, 'memberDataList[0].dobDate')
        dob.send_keys user.dob
        
        first_name = driver.find_element(:name, 'memberDataList[0].firstName')
        first_name.send_keys user.first_name
        
        last_name = driver.find_element(:name, 'memberDataList[0].lastName')
        last_name.send_keys user.last_name
        
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

          if driver.find_elements( :class,"oep-managed-sub-tab").second.displayed?
            driver.find_elements( :class,"oep-managed-sub-tab").second.click
          end

          sleep(4)

          wait.until { driver.find_elements(:class, 'collapseTable').present? }
 
          date_of_eligibility = driver.find_element(:css, '.patient-results-onDate > span').attribute('innerHTML')
          
          containers = driver.find_elements(:class, 'collapseTable-container')

          @json = User.parse_containers(containers, date_of_eligibility)

          if @json
            user.update_attribute('record_available', true)
          end

          driver.quit

          user.update_attribute('json', @json)

        
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
