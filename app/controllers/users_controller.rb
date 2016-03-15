class UsersController < ApplicationController

	
  def access_token
    if params[:user].present? && params[:user][:first_name] && params[:user][:last_name] && params[:user][:dob].present? && params[:user][:patient_id].present? && params[:user][:password].present? && params[:user][:username].present? && params[:user][:site_url].present?      
      site_url = params[:user][:site_url]
      token = SecureRandom.base64(24)
      
      params[:user].merge!({token: token})
      
      user = User.create(params[:user])
      
      if user
        result = params[:user]

        if site_url.include?('cignaforhcp')
          Delayed::Job.enqueue Crawler.new(user.first_name, user.last_name, user.dob, user.patient_id, user.username, user.password, user.token, user.id, user.site_url)
          
          user.update_attribute('record_available', 'pending')
        
        elsif site_url.include?('mhnetprovider')
          Delayed::Job.enqueue MhnetCrawler.new(user.patient_id, user.username, user.password, user.token, user.id, user.site_url)
          
          user.update_attribute('record_available', 'pending')
        end  
      end
    
    else
      result = 'Not permitted'
    end
    
    render json: result
  end
  

  def create
    site_url = params[:user][:site_to_scrap]

    obj = sign_in(params[:user][:username], params[:user][:password], site_url)
    
    driver = obj[:driver]
    previous_url = obj[:previous_url]

    if driver.current_url.split("/").last.include?(obj[:error]) || driver.current_url == previous_url
      flash[:danger] = "Please enter correct information"
    
    else
      flash[:success] = 'Login Successful'
      session[site_url] = {username: params[:user][:username], password: params[:user][:password]}
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
      search_data(user, params[:user][:username], params[:user][:password], params[:user][:site_to_scrap])
    end
  end
  
  def show(id)
    user=User.find(id)
    @json=user.json
    render "search_data"
  end

  
  def delete_all
    User.destroy_all
    redirect_to :back
  end


  def sign_in(name, pass, site_url)
    fields = User.retrieve_signin_fields(site_url)
    
    wait = Selenium::WebDriver::Wait.new(timeout: 20)
    
    driver = Selenium::WebDriver.for :firefox
    # , :args => ['--ignore-ssl-errors=true']
    
    driver.navigate.to site_url

    current_url = driver.current_url

    username = driver.find_element(:name, fields[:user_field])
    username.send_keys name

    password = driver.find_element(:name, fields[:pass_field])
    password.send_keys pass

    element = driver.find_element(:css, fields[:submit_button])
    element.submit

    {driver: driver, previous_url: current_url, wait: wait, error: fields[:error_string]}
  end


  def search_data(user, username, password, site_url)
    if user.first_name.present? && user.last_name.present? && user.dob.present? && user.patient_id.present?        
      if site_url.include?('cignaforhcp')
        Delayed::Job.enqueue Crawler.new(user.first_name, user.last_name, user.dob, user.patient_id, username, password, nil, user.id, site_url)
      
      elsif site_url.include?('mhnetprovider')
        Delayed::Job.enqueue MhnetCrawler.new(user.patient_id, username, password, nil, user.id, site_url)
      end

      user.update_attribute('record_available', 'pending')

      flash['info'] = "Process has been initiated for patient = #{user.patient_id}"

      redirect_to :back 
    end 
  end


  
end
