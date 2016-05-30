class PatientsController < ApplicationController
  skip_before_filter :authenticate_user!

  def access_token
    if params[:patient].present? && params[:patient][:first_name] && params[:patient][:last_name] && params[:patient][:dob].present? && params[:patient][:patient_id].present? && params[:patient][:password].present? && params[:patient][:username].present? && params[:patient][:site_url].present?
      site_url = params[:patient][:site_url]
      token = SecureRandom.urlsafe_base64(24)

      params[:patient].merge!({token: token})

      patient = Patient.create(first_name: params[:patient][:first_name],last_name: params[:patient][:last_name], dob: params[:patient][:dob], patient_id: params[:patient][:patient_id], password: params[:patient][:password], username:params[:patient][:username], token: token, site_url: site_url)

      result = params[:patient]

    else
      result = 'Not permitted'
    end

    render json: result
  end
  
  def authenticate_token
    if params[:patient].present? && params[:patient][:first_name].present? && params[:patient][:last_name].present? && params[:patient][:dob].present? && params[:patient][:patient_id].present? && params[:patient][:password].present? && params[:patient][:username].present? && params[:patient][:site_url].present? && params[:patient][:token].present?
      res = params[:patient]

      # patient = Patient.find(:all, :conditions => ['token=?', res[:token]]).last

      patient = Patient.find_by_token(res[:token])

      puts patient.present?
      if patient.present?
        site_url = patient.site_url

        result = 'Your requested process has been initiated'

        if site_url.include?('cignaforhcp')
          Delayed::Job.enqueue Crawler.new(patient.first_name, patient.last_name, patient.dob, patient.patient_id, patient.username, patient.password, patient.token, patient.id, patient.site_url, res[:redirect_url])
          patient.update_attribute('record_available', 'pending')

        elsif site_url.include?('mhnetprovider')
          Delayed::Job.enqueue MhnetCrawler.new(patient.id, patient.patient_id, patient.username, patient.password, patient.token, patient.site_url, res[:redirect_url])
          patient.update_attribute('record_available', 'pending')

        elsif site_url.include?('availity')
          Delayed::Job.enqueue AvailityCrawler.new(patient.id, patient.patient_id, patient.dob, patient.username, patient.password, patient.site_url, res[:redirect_url], patient.token, res['practice_name'], res['practice_name_code'], res['cus_field2_code'],res['provider_name'], res['provider_name_code'],res['cus_field4_code'],res['service_type_code'])
          patient.update_attribute('record_available', 'pending')

        elsif site_url.include?('navinet')
          Delayed::Job.enqueue AetnaCrawler.new(patient.username, patient.password, patient.patient_id, patient.site_url, res[:redirect_url], patient.token)
          patient.update_attribute('record_available', 'pending')  

        end

      else
        result = 'Patient is Invalid'
      end

    else
      result = 'Not permitted'
    end

    render json: result
  end


  def create

    site_url = params[:patient][:site_to_scrap]

    obj = sign_in(params[:patient][:username], params[:patient][:password], site_url)

    driver = obj[:driver]
    previous_url = obj[:previous_url]

    if (!site_url.include?('availity') == true && driver.current_url.split("/").last.include?(obj[:error]) == true) || driver.current_url == previous_url || driver.current_url == "https://apps.availity.com/availity/web/public.elegant.login"
      flash[:danger] = "Please enter correct information"

    else
      flash[:success] = 'Login Successful'
      session[site_url] = {username: params[:patient][:username], password: params[:patient][:password]}
    end

    driver.quit
    redirect_to :back
  end


  def import
    Patient.import(params[:file])
    redirect_to root_url, notice: "Patients imported."
  end


  def update
    patient=Patient.find(params[:id])
    if patient.json.present?
      show(patient.id)
    else
      search_data(patient, params[:patient][:username], params[:patient][:password], params[:patient][:site_to_scrap])
    end
  end

  def show(id)
    patient=Patient.find(id)
    @json=patient.json
    render "search_data"
  end

  def transaction_logs
    @patients =  Patient.all
    
  end

  def import_mapping
    id = params[:format] if params[:format].present?
    Patient.import_mapping(params[:file],id)
    redirect_to :back, notice: "Mapping Code updated."
  end


  def delete_all
    Patient.destroy_all
    redirect_to :back
  end


  def s_in(name, pass, site_url)
    
    fields = Patient.retrieve_signin_fields(site_url)
    fields_hash = []

    wait = Selenium::WebDriver::Wait.new(timeout: 20)

    driver = Selenium::WebDriver.for :firefox
    # :phantomjs, :args => ['--ignore-ssl-errors=true']

    driver.navigate.to site_url

    current_url = driver.current_url

    username = driver.find_element(:name, fields[:user_field])
    username.send_keys name

    fields_hash << {"Username Field" => "Found"}

    password = driver.find_element(:name, fields[:pass_field])
    password.send_keys pass
    fields_hash << {"Password Field" => "Found"}


    element = driver.find_element(:css, fields[:submit_button])
    
    if fields[:user_field] == 'userId'
      element.click
      sleep(4)
    else
      element.submit
    end
    fields_hash << {"Login Button" => "Found"}
    
    {driver: driver, previous_url: current_url, wait: wait, error: fields[:error_string], fields_hash: fields_hash}
  end

  def sign_in_api
    patient = params[:patient]
    if patient[:username].present? && patient[:password].present? && patient[:site_url].present?
      result = s_in(patient[:username], patient[:password], patient[:site_url])

      if (!patient[:site_url].include?('availity') == true && result[:driver].current_url.split("/").last.include?(result[:error]) == true ) || result[:driver].current_url == result[:previous_url] || result[:driver].current_url == "https://apps.availity.com/availity/web/public.elegant.login"
       # result[:driver].current_url == result[:previous_url] || result[:driver].current_url == "https://apps.availity.com/availity/web/public.elegant.login"
        
        puts "-="*23
        render json: false

      else
        render json: true
      end

      result[:driver].quit

    else
      render json: "not permitted"
    end
  end


  def sign_in(name, pass, site_url)
    result = s_in(name, pass, site_url)

    {driver: result[:driver], previous_url: result[:previous_url], wait: result[:wait], error: result[:error], fields_hash: result[:fields_hash].reduce({},:merge)}
  end


  def search_data(patient, username, password, site_url)
    if patient.first_name.present? && patient.last_name.present? && patient.dob.present? && patient.patient_id.present?
      if site_url.include?('cignaforhcp')
        Delayed::Job.enqueue Crawler.new(patient.first_name, patient.last_name, patient.dob, patient.patient_id, username, password, nil, patient.id, site_url)

      elsif site_url.include?('mhnetprovider')
        Delayed::Job.enqueue MhnetCrawler.new(patient.id, patient.patient_id, username, password, nil, site_url, nil)

      elsif site_url.include?('availity')
        puts "in here"
        Delayed::Job.enqueue AvailityCrawler.new(patient.id,patient.patient_id,patient.dob, username, password, site_url,nil,nil, 'Psyc', '313030', 'CIGNA', 'DATTA, GAUTAM', '1528269982','11','MH')

      elsif site_url.include?('navinet')
        Delayed::Job.enqueue AetnaCrawler.new(username, password, patient.patient_id, site_url, nil, nil)
      end



      patient.update_attribute('record_available', 'pending')
      flash['info'] = "Process has been initiated for patient = #{patient.patient_id}"

      redirect_to :back
    end
  end

  private
    # def patient_params
    #   params.require(:patient).permit( :record_available, :dob, :first_name, :last_name, :patient_id, :username, :password, :site_to_scrap, :token, :raw_html, :json, :site_url, :practice_name, :payer_name, :provider_type, :place_of_service, :service_type, :practice_name_code, :cus_field2_code, :provider_name, :provider_name_code, :cus_field4_code, :service_type_code)
    # end

end
