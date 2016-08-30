class AvailityApi
  def send(params)
    begin     
      
      fields = Patient.retrieve_signin_fields(params[:site_url])
      puts fields
      
      customer_id = params[:customer_id]
      payerId = params[:payer_id]

      provider_lastname = params[:p_last_name]
      providerNpi = params[:p_npi]
      
      capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs
      capabilities['phantomjs.page.customHeaders.X-Availity-Customer-ID'] = customer_id
      browser = Watir::Browser.new :phantomjs, :args => ['--ignore-ssl-errors=true'], desired_capabilities: capabilities

      browser.goto "https://apps.availity.com/availity/web/public.elegant.login"

      username_i = browser.element(:name, fields[:user_field])
      username_i.send_keys params[:username]

      password = browser.element(:name, fields[:pass_field])
      password.send_keys params[:pass]

      element = browser.element(:css, fields[:submit_button])
      element.click
      puts "logged in"

      sleep(3)
      browser.goto "https://apps.availity.com/public/apps/eligibility"
      
      browser.goto "https://apps.availity.com/api/v1/users/me"
      me = Crack::XML.parse(browser.html)

      puts me

      providerUserId = me["APIResponse"]["User"]["id"] if me["APIResponse"].present? && me["APIResponse"]["User"].present?

      puts "providerUserId #{providerUserId}"

      # browser.goto "https://apps.availity.com/api/internal/v1/providers?customerId=#{customer_id}&limit=50"
      # npi = Crack::XML.parse(browser.html)



      # npi_code = npi["APIResponse"]["Provider"].keep_if{|provider| provider['lastName'] == patient_name.split(',').first.strip && provider['firstName'] == patient_name.split(',').last.strip}.reduce

      # providerNpi = npi_code['npi']      

      sleep(2)
      
      pat_dob = params[:dob].split('/')
      pat_dob = pat_dob[2]+"-"+pat_dob[0]+"-"+pat_dob[1]
puts pat_dob

      # request_url = "https://apps.availity.com/api/v1/coverages?asOfDate="+Time.now.strftime("%Y-%m-%d")+"&customerId="+"388016"+"&memberId="+patient_id+"&patientBirthDate="+pat_dob+"&payerId=#{payer_name}&placeOfService=#{place_service_val}&providerLastName=#{name_of_organiztion}&providerNpi=1447277447&providerType=AT&providerUserId=aka65481841532&serviceType=#{benefit_val}&subscriberRelationship=18" 

      request_url = "https://apps.availity.com/api/v1/coverages?asOfDate="+Time.now.strftime("%Y-%m-%d")+"&customerId="+customer_id+"&memberId="+params[:ins_id]+"&patientBirthDate="+pat_dob+"&payerId="+payerId+"&providerLastName="+provider_lastname+"&providerNpi="+providerNpi+"&providerUserId="+providerUserId+"&serviceType="+params[:service_type]+"&providerType=AT"
puts request_url


      browser.goto request_url 
      sleep(2)
      js = nil
      ret = Crack::XML.parse(browser.html)

      puts ret
      
      if ret["APIResponse"].present?
        browser.goto ret["APIResponse"]["Coverage"]["links"]["self"]["href"]
        sleep(2)
        a = browser.html
        
        puts ret["APIResponse"]["Coverage"]["links"]["self"]["href"]
        js = Crack::XML.parse(a)
      end

      browser.quit      

      puts js

      if js.present?
        @json_arr = []
        @json_arr = Patient.new_jsn(js)

        sleep(2)
        @json = JSON.generate(@json_arr)

      return @json_arr
                
      end
    rescue Exception=> e
      return e.inspect

    end
 
  end
end

# customer_id = 388016
    # username = 'statpay'
    #pass = 'Swervepay0!'
 # site_url = 'https://apps.availity.com/'

 #patient_dob = '08/25/1950'

 # payerId = 'BCBSIL'
 #provider_lastname = 'NORTHWEST+MEDICAL+CARE'
 #providerNpi = '1447277447'
 #service_type = '30'
 #patient_id = 'MUPXZ3775081'

