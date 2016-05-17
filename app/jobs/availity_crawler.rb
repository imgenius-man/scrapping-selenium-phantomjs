class AvailityCrawler < Struct.new(:pat_id,:patient_id,:patient_dob,:username,:pass,:site_url, :response_url, :token, :name_of_organiztion,:payer_name,:provider_name,:place_service_val,:benefit_val)

  def perform
    begin     
      patient = Patient.find(pat_id)
    
      puts "=="*40
      puts patient_id
      puts "--"*40
      puts patient_dob
      puts "++"*40 
      puts  username
      puts "<->"*40
      puts pass
      puts "؟-?"*40 
      puts site_url
      puts "=="*40
      username = 'ewomack'
      pass = 'Pcc@63128' 
      site_url = Patient.options_for_site[2][1]
      
      fields = Patient.retrieve_signin_fields(site_url)
      puts fields
      capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs
      capabilities['phantomjs.page.customHeaders.X-Availity-Customer-ID'] = '313030'
      browser = Watir::Browser.new :phantomjs, :args => ['--ignore-ssl-errors=true'], desired_capabilities: capabilities

      browser.goto "https://apps.availity.com/availity/web/public.elegant.login"

      username_i = browser.element(:name, fields[:user_field])
      username_i.send_keys username

      password = browser.element(:name, fields[:pass_field])
      password.send_keys pass

      element = browser.element(:css, fields[:submit_button])
      element.click

      sleep(5)
      puts "logged in"
      pat_dob = patient_dob.split("/")
      pat_dob = pat_dob[2]+"-"+pat_dob[0]+"-"+pat_dob[1]


      # request_url = "https://apps.availity.com/api/v1/coverages?asOfDate="+Time.now.strftime("%Y-%m-%d")+"&customerId="+"388016"+"&memberId="+patient_id+"&patientBirthDate="+pat_dob+"&payerId=#{payer_name}&placeOfService=#{place_service_val}&providerLastName=#{name_of_organiztion}&providerNpi=1447277447&providerType=AT&providerUserId=aka65481841532&serviceType=#{benefit_val}&subscriberRelationship=18" 

      request_url = "https://apps.availity.com/api/v1/coverages?asOfDate="+Time.now.strftime("%Y-%m-%d")+"&customerId="+"313030"+"&memberId="+patient_id+"&patientBirthDate="+pat_dob+"&payerId=241&providerLastName=DATTA&providerNpi=1568688414&providerUserId=aka65481841532&serviceType=MH" 



      browser.goto request_url 
      sleep(2)
      js = nil
      ret = Crack::XML.parse(browser.html)

      puts ret
      
      if ret["APIResponse"].present?
        browser.goto ret["APIResponse"]["Coverage"]["links"]["self"]["href"]
        sleep(2)
        js = Crack::XML.parse(browser.html)
      end

      browser.quit      

      puts js

      if js.present?
        @json_arr = []
        @json_arr = Patient.new_jsn(js)

        sleep(2)
        puts @json_arr.inspect
        puts "wapis to aa gya ha"
        @json = JSON.generate(@json_arr)

        puts @json.inspect

        patient.update_attribute('json', @json)
        patient.update_attribute('record_available', 'complete')

        if response_url.present?
          response = RestClient.post response_url, {data: @json, token: token}
        end
      end
    rescue Exception=> e
      patient.update_attribute('record_available', 'failed')

      PatientMailer::exception_email("PatientID: #{patient_id} ==> #{e.inspect} \n WebSite = production").deliver

    end
 
  end
end
