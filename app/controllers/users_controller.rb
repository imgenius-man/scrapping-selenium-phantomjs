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
    obj = signin_cigna(params[:user][:username], params[:user][:password], params[:user][:site_to_scrap])
    
    driver = obj[:driver]
    previous_url = obj[:previous_url]

    if driver.current_url.split("/").last.include?('error') || driver.current_url == previous_url
      flash[:danger] = "Please enter correct information"
    
    else
      flash[:success] = 'Login Successful'
      session[:username] = params[:user][:username]
      session[:password] = params[:user][:password]
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
      search_data(user, params[:user][:username], params[:user][:password])
    end
  end

  
  def show(id)
    user=User.find(id)
    @json=user.json
    render "search_data"
  end

  def signin_cigna(name, pass, site_url)
    wait = Selenium::WebDriver::Wait.new(timeout: 20)
    
    driver = Selenium::WebDriver.for :phantomjs, :args => ['--ignore-ssl-errors=true']
    
    driver.navigate.to "https://cignaforhcp.cigna.com/web/secure/chcp/windowmanager#tab-hcp.pg.patientsearch$1"

    current_url = driver.current_url

    username = driver.find_element(:name, 'username')
    username.send_keys name

    password = driver.find_element(:name, 'password')
    password.send_keys pass

    element = driver.find_element(:id, 'button1')
    element.submit

    {driver: driver, previous_url: current_url}
  end


  def search_data(user, username, password)
    if user.first_name.present? && user.last_name.present? && user.dob.present? && user.patient_id.present?        
      Delayed::Job.enqueue Crawler.new(user.first_name, user.last_name, user.dob, user.patient_id, username, password, nil, user.id)
      
      user.update_attribute('record_available', 'pending')

      flash['info'] = "Process has been initiated for patient = #{user.patient_id}"

      redirect_to :back 
    end 
  end


  
end
