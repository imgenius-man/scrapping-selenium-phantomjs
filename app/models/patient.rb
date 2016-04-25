class Patient < ActiveRecord::Base
  require 'csv'
  require 'parsers/parse_container'
  require 'parsers/parse_availity'

  extend PatientsHelper

  attr_accessible :record_available, :dob, :first_name, :last_name, :patient_id, :username, :password, :site_to_scrap, :token, :raw_html, :json, :site_url

  serialize :json, JSON


  def self.new_availity(patient_id,patient_dob,u_name,pass,site_url)#,name_of_organiztion,payer_name,provider_name,place_service_val,benefit_val)
    
    puts "=="*42
    puts patient_id
    puts "--"*42
    puts patient_dob
    puts "++"*42  
    # u_name = 'prospect99'
    # pass = 'Medicare#20' 
    # site_url = Patient.options_for_site[2][1]
    

    fields = Patient.retrieve_signin_fields(site_url)

    capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs
    capabilities['phantomjs.page.customHeaders.X-Availity-Customer-ID'] = '388016'
    browser = Watir::Browser.new :phantomjs, :args => ['--ignore-ssl-errors=true'], desired_capabilities: capabilities

    browser.goto "https://apps.availity.com/availity/web/public.elegant.login"

    username = browser.element(:name, fields[:user_field])
    username.send_keys u_name

    password = browser.element(:name, fields[:pass_field])
    password.send_keys pass

    element = browser.element(:css, fields[:submit_button])
    element.click

    sleep(5)

    pat_dob = patient_dob.split("/")
    pat_dob = pat_dob[2]+"-"+pat_dob[0]+"-"+pat_dob[1]

    request_url = "https://apps.availity.com/api/v1/coverages?asOfDate="+Time.now.strftime("%Y-%m-%d")+"&customerId="+"388016"+"&memberId="+patient_id+"&patientBirthDate="+pat_dob+"&payerId=BCBSIL&placeOfService=11&providerLastName=NORTHWEST+MEDICAL+CARE&providerNpi=1447277447&providerType=AT&providerUserId=aka61272640622&serviceType=30&subscriberRelationship=18"

    browser.goto request_url 
    sleep(2)
    js = nil
    ret = Crack::XML.parse(browser.html)
    if ret["APIResponse"].present?
      browser.goto ret["APIResponse"]["Coverage"]["links"]["self"]["href"]
      sleep(2)
      js = Crack::XML.parse(browser.html)
    end

    browser.quit      

    new_jsn(js)
  
  end


  def self.new_jsn(json_obj)

    json = ParseAvaility.new.parse_panels(json_obj)

  end

  def self.clean(id)
    a=Patient.find(id)
    a.raw_html = nil
    a.json = nil
    a.record_available = "failed"
    a.save
  end

  def self.parse_containers(containers, date_of_eligibility, eligibility_status, transaction_date)
    @cont = ParseContainer.new.tabelizer(containers)

    @json = []

    @cont.each do |cont|
      cont[1..cont.length].each do |con|
       @json << ParseTable.new.json_table(con[:table], cont.first[:name], con[:header_count], con[:additional_info], cont.last[:info])
      end
    end

    @json.reject!(&:nil?).reject!{|a| a == false}
      @json = [{'General' => {'ELIGIBILITY AS OF' => date_of_eligibility, 'ELIGIBILITY STATUS' => eligibility_status, 'TRANSACTION DATE' => transaction_date}}] + @json

    @json
  end


  def self.retrieve_signin_fields(site_url)
    options = Patient.options_for_site

    if site_url == options[0][1]
      fields = {user_field: 'username', pass_field: 'password', submit_button: '#button1', error_string: 'error'}

    elsif site_url == options[1][1]
      fields = {user_field: 'portletInstance_6{actionForm.userId}', pass_field: 'portletInstance_6{actionForm.password}', submit_button: '.button_submit', error_string: 'login'}
    elsif site_url == options[2][1]
      fields = {user_field: 'userId', pass_field: 'password', submit_button: '#loginFormSubmit', error_string: 'login-failed'}
    end

    fields
  end


  def self.import(file)
      CSV.foreach(file.path, headers: true) do |row|
      user_hash = row.to_hash
      str = row.to_s.split(',')

      a= Patient.find_by_patient_id(str[3])
      if a
        a.update_attributes(first_name: str[0],last_name: str[1],dob: str[2],patient_id: str[3])
      else
        a=Patient.new
        a.first_name = str[0].squish if str[0]
        a.last_name = str[1].squish if str[1]
        a.dob = str[2].squish if str[2]
        a.patient_id = str[3].squish if str[3]
        a.save!
      end
    end
  end

  def self.import_mapping(file,id)
    obj = Status.find(id).service_types
    ServiceType.where(status_id: id).destroy_all

    CSV.foreach(file.path, headers: true) do |row|
      user_hash = row.to_hash
      str = row.to_s.split(',')

    if row.to_s.scan(/,/).count > 1
      new_str=[]
      new_str[0]=""
      str[0..str.count-2].each {|d|
        new_str[0] = new_str[0] + d + " "
      }
      new_str[1] = str[str.count-1].strip
      str = new_str
    end

        obj.create(type_name: (str[0].squish if str[0].present?), type_code: (str[1].squish if str[1].present?))

    end
  end

end