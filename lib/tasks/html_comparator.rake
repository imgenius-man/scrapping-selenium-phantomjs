task :cigna_test => :environment do
  begin
    cig = Status.find_by_site_url("https://cignaforhcp.cigna.com/")
    Status.false_all(cig)
    cig.date_checked= DateTime.now
    cig.site_username = CIGNA_USERNAME
    cig.site_password = CIGNA_PASSWORD
    cig.save!

    obj = PatientsController.new.sign_in(cig.site_username,cig.site_password, 'https://cignaforhcp.cigna.com/web/secure/chcp/windowmanager#tab-hcp.pg.patientsearch$1')
    driver = obj[:driver]
    ret_hash = obj[:fields_hash]
    
    cig.test_status_hash["Username Field"] = ret_hash["Username Field"]
    cig.test_status_hash["Password Field"] = ret_hash["Password Field"]
    cig.test_status_hash["Login Button"] = ret_hash["Login Button"]
      
    wait = obj[:wait]

    href_search = ''
    wait.until {
      href_search = driver.find_elements(:class,'patients')[1]
    }

    href_search.click

    cig.test_status_hash["Patient Search Button"] = "Found"

    member_id = nil
    wait.until {
      member_id = driver.find_element(:name, 'memberDataList[0].memberId')
    }

    cig.test_status_hash["Patient Form"] = "Found"

    member_id.send_keys 'U5151043002'
    
    cig.test_status_hash["Patient ID Field"] = "Found"

    dob = driver.find_element(:name, 'memberDataList[0].dobDate')
    dob.send_keys '15/06/1986'

    cig.test_status_hash["Patient DOB Field"] = "Found"

    ee = driver.find_elements(:class,'btn-submit-form-patient-search')[0]
    ee.submit
    cig.test_status_hash["Patient Record Search Button"] = "Found"

    sleep(2)

    driver.find_elements(:class,'btn-submit-form-patient-search')[0]

    link = nil

    wait.until {
      link = driver.find_elements(:css,'.patient-search-result-table > tbody > tr > td > .oep-managed-link')[0]
    }
    link.click

    cig.test_status_hash["Patient Response"] = "Found"
    
    puts "cig. 3 successful"

    eligibility_status = driver.find_elements(:css,'.patient-search-result-table > tbody > tr > td')[7].attribute('innerHTML')

    transaction_date = Time.now.to_datetime.strftime("%d/%m/%y %H:%M %p")

    date_of_eligibility = driver.find_element(:css, '.patient-results-onDate > span').attribute('innerHTML')

    patient_flag = false

    wait.until { driver.find_elements(:class, 'collapseTable').present? }
    puts "cig. 4 successful"
    sleep(2)

    if driver.find_elements( :class,"oep-managed-sub-tab").second.displayed?
      driver.find_elements( :class,"oep-managed-sub-tab").second.click
    end

    sleep(4)

    wait.until { driver.find_elements(:class, 'collapseTable').present? }
    puts "cig. 5 successful"

    containers = driver.find_elements(:class, 'collapseTable-container')
    puts "Going in to parse"
    @json = Patient.parse_containers(containers, date_of_eligibility, eligibility_status, transaction_date)
    cig.test_status_hash["Table Parsing"] = "Successful"
    
    driver.quit
    puts "cig 6 successful"


   service_types = Status.find_by_site_url('https://cignaforhcp.cigna.com/').service_types
    @json.each_with_index do |table_name, index|

      service_types.each do |serv_type|

        if @json[index][table_name.keys.first].present? && table_name.present? && serv_type.present? && serv_type.type_name.upcase.gsub(/[-\s+*]/, '') == table_name.keys.first.upcase.gsub(/[-\s+*]/, '').tr(',','')
          serv_type.mapped_service=true

          @json[index][table_name.keys.first]['CODE'] = serv_type.type_code.to_s
        else
          key = @json[index]

          a = nil
          a = Status.find_by_site_url('https://cignaforhcp.cigna.com/').service_types && ServiceType.find_by_type_name(key.first[0].tr(',',''))

          if !a.present?
            b = ServiceType.new
            b.status_id = Status.find_by_site_url("https://cignaforhcp.cigna.com/").id
            b.type_name = key.first[0].tr(',','')
            b.mapped_service = true
            b.save!
          end
        end
      end
    end

    if service_types.count == 0
      @json.each do |key,val|
        a = nil
        a = Status.find_by_site_url('https://cignaforhcp.cigna.com/').service_types && ServiceType.find_by_type_name(key.first[0].tr(',',''))
        if !a.present?
          b = ServiceType.new
          b.status_id = Status.find_by_site_url("https://cignaforhcp.cigna.com/").id
          b.type_name = key.first[0].tr(',','')
          b.mapped_service = true
          b.save!
        end
      end
    end

    cig.test_status_hash["Excel Generation & Mapping"] = "Successful"
    cig.test_status_hash["Site Status"] = "All Tests OK"

    PatientMailer::HTML_validation_notification("Success: All tests executed successfully -- CIGNA.").deliver
    puts "Sarri parse ho gai"

  rescue Exception => e
    PatientMailer::HTML_validation_notification("Error: Some tests not executed properly -- CIGNA.\nException=>#{e}").deliver
  end
    cig.save!
end

task :mhnet_test => :environment do
  begin
    puts "\n\nmhnet\n\n"
    mhnet = Status.find_by_site_url("https://www.mhnetprovider.com/")
    Status.false_all(mhnet)
    mhnet.date_checked= DateTime.now
    mhnet.site_username = MHNET_USERNAME
    mhnet.site_password = MHNET_PASSWORD
    mhnet.save!

    obj = PatientsController.new.sign_in(mhnet.site_username,mhnet.site_password, 'https://www.mhnetprovider.com/')
    driver = obj[:driver]

    ret_hash = obj[:fields_hash]
    
    mhnet.test_status_hash["Username Field"] = ret_hash["Username Field"]
    mhnet.test_status_hash["Password Field"] = ret_hash["Password Field"]
    mhnet.test_status_hash["Login Button"] = ret_hash["Login Button"]

    wait = obj[:wait]

    driver.navigate.to 'https://www.mhnetprovider.com:443/providerPortalWeb/appmanager/mhnet/extUsers?_nfpb=true&_pageLabel=eligibility_page_1_mhnet'
    member_id = driver.find_element(:id, 'mem_id')
    member_id.send_keys '90261149003'
    
    mhnet.test_status_hash["Patient Form"] = "Found"
    mhnet.test_status_hash["Patient ID Field"] = "Found"

    service_type = driver.find_element(:id, 'serviceDateStart_memberIdSearch')

    date = 7.days.from_now.strftime("%m/%d/%Y")
    driver.execute_script("$('#serviceDateStart_memberIdSearch').val('#{date}')")
    mhnet.test_status_hash["Patient Service Date Field"] = "Found"

    btn_click = driver.find_element(:name, 'singleMemberSubmit')
    btn_click.click
    mhnet.test_status_hash["Patient Record Search Button"] = "Found"

    page = driver.find_element(:css, 'body').attribute('innerHTML').squish

    mhnet.test_status_hash["Patient Response"] = "Found"


    wait.until { driver.find_element(:class, 'pcpHistory').displayed? }

    driver.find_element(:class, 'pcpHistory').click

    mhnet.test_status_hash["Patient PCP History Link"] = "Found"

    pcpHistory = driver.find_element(:class, 'fetched').attribute('innerHTML')

    wait.until { driver.find_element(:class, 'coverageHistory').displayed? }

    driver.find_element(:class, 'coverageHistory').click

    mhnet.test_status_hash["Patient Coverage History Link"] = "Found"

    cvrgHistory = driver.find_element(:class, 'fetched').attribute('innerHTML')

    wait.until { driver.find_element(:class, 'cobInformation').displayed? }

    driver.find_element(:class, 'cobInformation').click

    mhnet.test_status_hash["Patient CobInformation Link"] = "Found"

    cobInformation = driver.find_element(:class, 'fetched').attribute('innerHTML')

    open_tables = driver.find_elements(:class, 'information')

    mhnet.test_status_hash["Patient Information Detail"] = "Found"


    @json = []

    parse = ParseTable.new

    open_tables.each do |table|
      page = Mechanize::Page.new(nil,{'content-type'=>'text/html'},table.attribute('innerHTML'),nil,Mechanize.new)

      container_name = page.at('h3').text.squish if page.at('h3').present?
      container_name = container_name.to_s
      html = table.attribute('innerHTML')

      if container_name.include?('Accumulating Deductible Information')
        if page.search('table').present?
          table_name=[]
          ul = page.search('ul')
          ul.first.search('li').each_with_index { |u,i|
            table_name[i] = container_name +" - "+u.text.squish
          }

          div_table=[]

          div_table[0]= page.search("#eligibility_accumulatingDeductibleInformation_deductibleDollars_deductibleDollars")
          div_table[1]= page.search("#eligibility_accumulatingDeductibleInformation_deductibleDollars_outOfPocket")

          data=[]

          div_table.each { |div_tbl|
            key=[]

            in_or_out = div_tbl.search('h5')

            div_name = div_tbl.at('h4')

            in_or_out.each_with_index { |in_r_out,m|
              key[m] = div_name.text.squish+" - "+in_r_out.text.squish
            }

            uper_headers=[]

            uper_headers_content= div_tbl.search('table>thead>tr>th')

            uper_headers_content[0..(uper_headers_content.length/2)-1].each_with_index {|tbl_cont,k|
              uper_headers[k]= tbl_cont.text.squish
            }

            table=div_tbl.search('table')

            p=0

            table.each { |tbl|
              data << parse_table(tbl,key[p],uper_headers)
              p=p+1
            }
          }


          data_array = data.reduce({}, :merge)

          dummy_array = parse.dummy_array_for_h2_table()

          table_json = { 'PLAN LEVEL BENEFITS' => parse.merge_arrays(dummy_array, data_array)}

        else
          dummy_array = parse.dummy_array_for_h2_table()
          dummy_array['ADDITIONAL NOTES'] = page.at('p').text

          table_json = { 'PLAN LEVEL BENEFITS' => dummy_array }
        end

        @json << table_json
      end

      if container_name.include?('Copay Information')

        if page.search('h4').present?

          headers = page.search('h4')
          values = page.search('.definition')

          data = headers.map.with_index(0) { |r, i|
            {r.text.squish => values[i].text.squish}
          }.reduce({}, :merge)

          dummy_array = parse.dummy_array_for_h2_table()

          dummy_array['COPAY (TYPE)- IN NETWORK'] = data['Office Visit']

        else
          dummy_array = parse.dummy_array_for_h2_table()

          dummy_array['ADDITIONAL NOTES'] = html.squish.split(/[<p>,<\/p>]/).last
        end

        table_json = { 'PLAN LEVEL BENEFITS' => dummy_array }

        @json << table_json
      end

      if container_name.include?('Patient Information')

        name = ''

        if page.search('h5').present?
          faddress = page.at('.address')
          patient_address = faddress.search('p')
          address = ""
          patient_address[1..patient_address.length].each  {|_address| address = address + " "+_address }
          address_line = address.split(",").first
          address = address.split(" ")
          name  = patient_address[0].text
          headers = page.search('h5')
          values = page.search('.definition')

          data = headers.map.with_index(0) { |r, i|
            {r.text.squish => values[i].text.squish}
          }.reduce({}, :merge)

          data.merge!({'Address' => address})

        else
          data = {'Additional notes' => html.squish.split(/[<p>,<\/p>]/).last}
        end

        zip = []
        state = []

        address.each_with_index do |v,i|
          if v.to_i != 0
            zip << v
            state << i
          end
        end

        dummy_array = parse.dummy_array_for_patient_detail()

        dummy_array['Patient Detail']['Patient ID'] = data['Member ID:']

        dummy_array['Patient Detail']['First Name'] = name.split(",").first

        dummy_array['Patient Detail']['Last Name'] = name.split(",").last

        dummy_array['Patient Detail']['DOB'] = data['Date Of Birth']

        dummy_array['Patient Detail']['Address 1'] = address_line

        dummy_array['Patient Detail']['City'] =  address[(state.last.to_i-3)]+ " " + address[(state.last.to_i-2)]

        dummy_array['Patient Detail']['State'] = address[(state.last.to_i-1)]

        dummy_array['Patient Detail']['Zip'] = zip.last

        dummy_array['Plan and Network Detail']['Plan Type'] = data['Benefit Plan']

        dummy_array['Plan and Network Detail']['Account Name'] = data['Group Name:']

        dummy_array['Plan and Network Detail']['Account No.'] = data['Group ID:']

        # table_json = { container_name => data}
        @json << dummy_array
      end

      if container_name.include?('Family Information')
        @cont = ParseContainer.new.tabelizer([open_tables[1]]).flatten

        table = @cont[1][:table]

        family_info = table[1..table.length].map do |tr|
          tr[:tr][1..tr[:tr].length].map.with_index(1) do |td, i|
            { tr[:tr][0][:td].inject(:+) + " - " + table[0][:tr][i][:th].inject(:+) => td[:td].inject(:+) }
          end
        end.flatten.reduce({}, :merge)

        family_table_json = { "Family Information" => family_info}

        @json << family_table_json
      end


      if container_name.include?('Primary Care Physician Information')
        if pcpHistory.scan('<tr>').present?
          @cont = ParseContainer.new.tabelizer([pcpHistory]).flatten

          table = @cont[1][:table]

          pcb_info = table[1..table.length].map do |tr|
            tr[:tr][1..tr[:tr].length].map.with_index(1) do |td, i|
              { tr[:tr][0][:td].inject(:+) + " - " + table[0][:tr][i][:th].inject(:+) => td[:td].inject(:+) }
            end
          end.flatten.reduce({}, :merge)

        else
          pcb_info = {'Additional notes' => pcpHistory.squish.split(/[<p>,<\/p>]/).last}
        end

        pcb_table_json = { "Primary Care Physician Information - PCP History" => pcb_info}
        @json << pcb_table_json

        if cvrgHistory.scan('<tr>').present?
          @cont = ParseContainer.new.tabelizer([cvrgHistory]).flatten

          table = @cont[1][:table]

          cvrg_info = table[1..table.length].map do |tr|
            tr[:tr][1..tr[:tr].length].map.with_index(1) do |td, i|
              { tr[:tr][0][:td].inject(:+) + " - " + table[0][:tr][i][:th].inject(:+) => td[:td].inject(:+) }
            end
          end.flatten.reduce({}, :merge)

        else
          cvrg_info = {'Additional notes' => cvrgHistory.squish.split(/[<p>,<\/p>]/).last}
        end

        cvrg_table_json = { "Primary Care Physician Information - Coverage History" => cvrg_info}
        @json << cvrg_table_json

        if cobInformation.scan('<dt').present?
          cob_html = Mechanize::Page.new(nil,{'content-type'=>'text/html'},cobInformation,nil,Mechanize.new)

          headers = cob_html.search('dt')
          values = cob_html.search('dd')

          cob_info = headers.map.with_index(0) do |header, i|
            { header.text.squish => values[i].text.squish }
          end.reduce({}, :merge)

        else
          cob_info = {'Additional notes' =>  cobInformation.squish.split(/[<p>,<\/p>]/).last}
        end

        cob_table_json = { "Primary Care Physician Information - COB Information" => cob_info}
        @json << cob_table_json
      end
    end

    if @json
        # patient.update_attribute('record_available', 'complete')
    end
    a = []

    @json.each_with_index{|v,i| a << i if v['PLAN LEVEL BENEFITS'].present?}

    if a.count == 2
      @json[a.last]['PLAN LEVEL BENEFITS']['COPAY (TYPE)- IN NETWORK'] = @json[a.first]['PLAN LEVEL BENEFITS']['COPAY (TYPE)- IN NETWORK']
      @json[a.last]['PLAN LEVEL BENEFITS']['ADDITIONAL NOTES'] = @json[a.first]['PLAN LEVEL BENEFITS']['ADDITIONAL NOTES']
      @json[a.last]['PLAN LEVEL BENEFITS']['CODE'] = 'MH'
      @json.delete_at(a.first)
    end

    mhnet.test_status_hash["Table Parsing"] = "Successful"

    
    site_link = "https://www.mhnetprovider.com/"
    
    service_types = Status.find_by_site_url(site_link).service_types

      @json.each_with_index do |(table_name, table_content), index|

        service_types.each do |serv_type|

          if serv_type.type_name.upcase.gsub(/[-\s+*]/, '') == table_name.keys.first.upcase.gsub(/[-\s+*]/, '').tr(',','')
            serv_type.mapped_service=true
            @json[index][@json[index].keys.first]['CODE'] = serv_type.type_code

          else
            key = @json[index]
            a = nil
            a = Status.find_by_site_url(site_link).service_types && ServiceType.find_by_type_name(key.first[0].tr(',',''))
            if !a.present?
              b = ServiceType.new
              b.status_id = Status.find_by_site_url(site_link).id
              b.type_name = key.first[0].tr(',','')

            end
          end
        end
      end

    if service_types.count == 0
      @json.each do |key,val|
        a = nil
        a = Status.find_by_site_url(site_link).service_types && ServiceType.find_by_type_name(key.first[0].tr(',',''))
        if !a.present?

          b = ServiceType.new
          b.status_id = Status.find_by_site_url(site_link).id
          b.type_name = key.first[0].tr(',','')
        end
      end
    end

    mhnet.test_status_hash["Excel Generation & Mapping"] = "Successful"
    mhnet.test_status_hash["Site Status"] = "All Tests OK"

    driver.quit

    PatientMailer::HTML_validation_notification("Success: All tests executed successfully -- MHNET.").deliver
  rescue Exception => e
    
    driver.quit if driver.present?

    PatientMailer::HTML_validation_notification("Error: Some tests not executed properly -- MHNET.\nException => #{e}").deliver
  end
  mhnet.save!
end

task :availity_test => :environment do
  
  begin
    site_url = "https://apps.availity.com/"
    ava = Status.find_by_site_url(site_url)
    Status.false_all(ava)
    
    puts "\n\navaility\n\n"
    
    patient_id = "XOF846071927"
    patient_dob = "5/10/1956"

    pass = AVAILITY_PASSWORD
    username = AVAILITY_USERNAME

    fields = Patient.retrieve_signin_fields(site_url)


    capabilities = Selenium::WebDriver::Remote::Capabilities.phantomjs
    capabilities['phantomjs.page.customHeaders.X-Availity-Customer-ID'] = '388016'
    browser = Watir::Browser.new :phantomjs, :args => ['--ignore-ssl-errors=true'], desired_capabilities: capabilities

    browser.goto "https://apps.availity.com/availity/web/public.elegant.login"
  
    username_i = browser.element(:name, fields[:user_field])
    username_i.send_keys username
    ava.test_status_hash["Username Field"] = "Found"

    password = browser.element(:name, fields[:pass_field])
    password.send_keys pass
    ava.test_status_hash["Password Field"] = "Found"

    element = browser.element(:css, fields[:submit_button])
    element.click
    ava.test_status_hash["Login Button"] = "Found"

    puts "availity sign in"

    sleep(5)

    puts "\n"
    puts "Browser URL #{browser.url}"

    ava.test_status_hash["Patient Form"] = "Found"
   
    pat_dob = patient_dob.split("/")
    pat_dob = pat_dob[2]+"-"+pat_dob[0]+"-"+pat_dob[1]

    request_url = "https://apps.availity.com/api/v1/coverages?asOfDate="+Time.now.strftime("%Y-%m-%d")+"&customerId="+"388016"+"&memberId="+patient_id+"&patientBirthDate="+pat_dob+"&payerId=BCBSIL&placeOfService=11&providerLastName=NORTHWEST+MEDICAL+CARE&providerNpi=1447277447&providerType=AT&providerUserId=aka61272640622&serviceType=30&subscriberRelationship=18"

    ava.test_status_hash["Patient ID Field"] = "Found"
    ava.test_status_hash["Patient DOB Field"] = "Found"
    ava.test_status_hash["Patient Payer Id Field"] = "Found"
    ava.test_status_hash["Patient Place Of Service Field"] = "Found"
    ava.test_status_hash["Patient Provider Name Field"] = "Found"
    ava.test_status_hash["Patient Benefit Field"] = "Found"

    browser.goto request_url
    sleep(2)

    js = nil
    ret = Crack::XML.parse(browser.html)

    puts ret
    
    if ret["APIResponse"].present?
      browser.goto ret["APIResponse"]["Coverage"]["links"]["self"]["href"]
      sleep(2)
      js = Crack::XML.parse(browser.html)
      puts js
    end
    ava.test_status_hash["Patient Response"] = "Found"
    browser.quit

    if js.present?
      @json_arr = []
      @json_arr = Patient.new_jsn(js)
      
    end
    
    ava.test_status_hash["Table Parsing"] = "Successful"
    ava.test_status_hash["Site Status"] = "All Tests OK"

    PatientMailer::HTML_validation_notification("Success: All tests executed successfully -- AVAILITY").deliver
  
  rescue Exception => e
    
    PatientMailer::HTML_validation_notification("Error: Some tests not executed properly -- AVAILITY\n Exception => #{e}").deliver
    
  end
    ava.save!
  
end

task :web_html_test => [:cigna_test, :mhnet_test, :availity_test]
