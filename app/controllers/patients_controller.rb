class PatientsController < ApplicationController

  def access_token
    if params[:patient].present? && params[:patient][:first_name] && params[:patient][:last_name] && params[:patient][:dob].present? && params[:patient][:patient_id].present? && params[:patient][:password].present? && params[:patient][:username].present? && params[:patient][:site_url].present?
      site_url = params[:patient][:site_url]
      token = SecureRandom.urlsafe_base64(24)

      params[:patient].merge!({token: token})

      patient = Patient.create(params[:patient])

      result = params[:patient]

    else
      result = 'Not permitted'
    end

    render json: result
  end


  def authenticate_token
    if params[:patient].present? && params[:patient][:first_name].present? && params[:patient][:last_name].present? && params[:patient][:dob].present? && params[:patient][:patient_id].present? && params[:patient][:password].present? && params[:patient][:username].present? && params[:patient][:site_url].present? && params[:patient][:token].present?
      res = params[:patient]

      patient = Patient.find(:all, :conditions => ['token=?', res[:token]]).last

      if patient.present?
        site_url = patient.site_url

        result = 'Your requested process has been initiated'

        if site_url.include?('cignaforhcp')
          Delayed::Job.enqueue Crawler.new(patient.first_name, patient.last_name, patient.dob, patient.patient_id, patient.username, patient.password, patient.token, patient.id, patient.site_url, res[:redirect_url])

          patient.update_attribute('record_available', 'pending')

        elsif site_url.include?('mhnetprovider')
          Delayed::Job.enqueue MhnetCrawler.new(patient.patient_id, patient.username, patient.password, patient.token, patient.id, patient.site_url, res[:redirect_url])

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

    if driver.current_url.split("/").last.include?(obj[:error]) || driver.current_url == previous_url
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

    wait = Selenium::WebDriver::Wait.new(timeout: 20)

    driver = Selenium::WebDriver.for :firefox#phantomjs, :args => ['--ignore-ssl-errors=true']

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

  def sign_in_api
    patient = params[:patient]
    if patient[:username].present? && patient[:password].present? && patient[:site_url].present?
      result = s_in(patient[:username], patient[:password], patient[:site_url])

      if result[:driver].current_url.split("/").last.include?(result[:error]) || result[:driver].current_url == result[:previous_url]
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

    {driver: result[:driver], previous_url: result[:previous_url], wait: result[:wait], error: result[:error]}
  end


  def search_data(patient, username, password, site_url)
    if patient.first_name.present? && patient.last_name.present? && patient.dob.present? && patient.patient_id.present?
      if site_url.include?('cignaforhcp')
        Delayed::Job.enqueue Crawler.new(patient.first_name, patient.last_name, patient.dob, patient.patient_id, username, password, nil, patient.id, site_url)

      elsif site_url.include?('mhnetprovider')
        Delayed::Job.enqueue MhnetCrawler.new(patient.patient_id, username, password, nil, patient.id, site_url)
      end

      patient.update_attribute('record_available', 'pending')

      flash['info'] = "Process has been initiated for patient = #{patient.patient_id}"

      redirect_to :back
    end
  end

end
