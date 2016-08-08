class AetnaCrawler < Struct.new(:username, :password, :patient_id, :site_url, :response_url, :token)


	def perform

    begin 
        puts "aa gya"
        puts "username: #{username}"
        puts "password: #{password}"
        puts "patient_id: #{patient_id}"
        puts "site_url: #{site_url}"
    
    patient = Patient.find_by_patient_id(patient_id)
    
    patient.update(website: 'Aetna')
    patient.update(request_id: 'Req'+patient.id.to_s)
    patient.update(request_datetime: Time.now)
    patient.update(response_id: token)
    
    puts "trying signing in"
    obj = PatientsController.new.sign_in(username, password, site_url)
    puts "sigin done"

    driver = obj[:driver]
    wait = obj[:wait]

    sleep(4)
    driver.navigate.to "https://navinet.navimedix.com/insurers/aetna/eligibility/eligibility-benefits-inquiry?start"
    sleep(15)
    driver.switch_to.frame('appContent')

    dropdown_list = driver.find_elements(:class, 'HandleSelectChange').first
    puts "3"
    options = dropdown_list.find_elements(tag_name: 'option')

    options.each { |option| option.click if option.text.include? 'Ahmad, Ijaz' }

    inp = driver.find_element(:name, 'DISPLAY_MemberID')
    inp.send_keys patient_id
    puts "4"
    #inp = driver.find_element(:name, 'DISPLAY_DateOfService')
    #inp.send_keys "8/24/1966"
    sleep(5)
    btn =  driver.find_element(:class , 'ButtonPrimaryAction')
    puts "5"
    btn.click

    #
    whether_active = driver.find_element(:css, ".Display > tbody:nth-child(1) > tr:nth-child(3) > td:nth-child(7)")
    whether_active = whether_active.text



    driver.find_element(:css, '.Display > tbody:nth-child(1) > tr:nth-child(3) > td:nth-child(9)').click
    
    sleep(5)

    puts driver.find_element(:tag_name,'body').attribute("innerHTML")

       
    # parsing
    patient_detail = ParseTable.new.dummy_array_for_patient_detail
    tables = driver.find_elements(:tag_name, 'table')

    member_info = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[2].attribute('innerHTML'),nil,Mechanize.new)

    subscriber_info = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[5].attribute('innerHTML'),nil,Mechanize.new)

    benefit_info = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[7].attribute('innerHTML'),nil,Mechanize.new)

    mega_arr = []

    if member_info.search('.clsEmphasized').present? && member_info.search('.clsEmphasized').first.text.squish == "Member Information"
      
      field_labels = member_info.search('.FieldLabel')
      field_data = member_info.search('.FieldData')

        ar = []
        indexes = []
        
        flag = true
        
        field_labels.each_with_index {|fl,index|
        
          if fl.present? && fl.text != " " && (flag || fl.text != "Address:")
            flag = false if fl.text == "Address:"
            key = fl.text.squish.split(':').first
            patient_detail["Patient Detail"]["First Name"] = field_data[index].text.squish.split(',').first if key.to_s.squish.include? 'Member Name'
            patient_detail["Patient Detail"]["Last Name"] = field_data[index].text.squish.split(',').last if key.to_s.squish.include? 'Member Name'
            patient_detail["Patient Detail"]["Address 1"] = field_data[index].text.squish if key.to_s.squish.include? 'Address'
            patient_detail["Patient Detail"]["Patient ID"] = field_data[index].text.squish if key.to_s.squish.include? 'Member ID'
            patient_detail["Patient Detail"]["DOB"] = field_data[index].text.squish if key.to_s.squish.include? 'Birth'
            patient_detail["Patient Detail"]["Relationship to Subscriber"] = field_data[index].text.squish if key.to_s.squish.include? 'Relation to Subscriber'
            patient_detail["Patient Detail"]["Gender"] = field_data[index].text.squish if key.to_s.squish.include? 'Gender'
            patient_detail["Patient Detail"]["PHONE NO."] = field_data[index].text.squish if key.to_s.squish.include? 'Phone Number'
            patient_detail["Plan and Network Detail"]["Account Name"] = field_data[index].text.squish if key.to_s.squish.include? 'Plan Name'
            patient_detail["Plan and Network Detail"]["Account No."] = field_data[index].text.squish if key.to_s.squish.include? 'Plan ID'
            patient_detail["Plan and Network Detail"]["Initial Coverage Date"] = field_data[index].text.squish if key.to_s.squish.include? 'Plan Effective Date'
          
            ar << { fl.text.squish.split(':').first => field_data[index].text.squish }
          
          elsif fl.present? && fl.text== " "
              indexes << index
          
          end
          
        }
        ar = ar.reduce({},:merge)
        ar["Address"] = ar["Address"]+", #{field_data[3].text.squish}"
        # mega_arr << {"Patient Detail" => ar}
    end
    

    if subscriber_info.search('.clsEmphasized').present? && subscriber_info.search('.clsEmphasized').first.text.squish == "Subscriber/Group Information"
      
      field_labels = subscriber_info.search('.FieldLabel')
      field_data = subscriber_info.search('.FieldData')
      ar = []
      field_labels.each_with_index {|fl,index|
        if fl.present? && fl.text != " "
          key = fl.text.squish.split(':').first
          patient_detail["Subscriber Detail"]["First Name"] = field_data[index].text.squish.split(',').first if key.to_s.squish.include? 'Subscriber Name'
          patient_detail["Subscriber Detail"]["Last Name"] = field_data[index].text.squish.split(',').last if key.to_s.squish.include? 'Subscriber Name'
          
          
          ar << { fl.text.squish.split(':').first => field_data[index].text.squish }
        end
      }

      # mega_arr << {"Subscriber Detail" => ar.reduce({},:merge)}

    end
    if benefit_info.search('.clsEmphasized').present? && benefit_info.search('.clsEmphasized').first.text.squish == "Benefit Description"
      field_labels = benefit_info.search('.FieldLabel')
      field_data = benefit_info.search('.FieldData')
      ar = []
      field_labels.each_with_index {|fl,index|
        if fl.present? && fl.text != " " && fl.text.present?
          ar << { fl.text.squish.split(':').first => field_data[index].text.squish }
        end
      }

      # mega_arr << {"Benefit Description" => ar.reduce({},:merge)}
    end
    mega_arr << patient_detail

    copay_ind = driver.execute_script(" return Array.prototype.indexOf.call($('#frmPlanForm > table'),$('#frmPlanForm > table > tbody > tr > th > a[name=\"Co payment\"]').closest('table')[0] )") + 4
    coin_ind = driver.execute_script(" return Array.prototype.indexOf.call($('#frmPlanForm > table'),$('#frmPlanForm > table > tbody > tr > th > a[name=\"Co insurance\"]').closest('table')[0] )") + 4
    oop_ind = driver.execute_script(" return Array.prototype.indexOf.call($('#frmPlanForm > table'),$('#frmPlanForm > table > tbody > tr > th > a[name=\"Deductible\"]').closest('table')[0] )") + 4
    deduc_ind = driver.execute_script(" return Array.prototype.indexOf.call($('#frmPlanForm > table'),$('#frmPlanForm > table > tbody > tr > th > a[name=\"Out of Pocket (Stop Loss)\"]').closest('table')[0] )") + 4

    amounts_arr = Patient.aetna_jsn(tables, copay_ind, coin_ind, oop_ind, deduc_ind)

    amounthash = amounts_arr.reduce({},:merge)
    amounts_arr.each{ |v|
      if amounthash[v.keys.first].present?
        v[v.keys.first].each{ |key,val|
          puts "+++"*100
          puts val
          amounthash[v.keys.first][key] = val if amounthash[v.keys.first][key].blank?
        }
      end
    }
    mega_arr << amounthash

    @json = JSON.generate(mega_arr)

    puts @json.inspect

    patient.update_attribute('json', @json)
    patient.update_attribute('record_available', 'complete')
    if response_url.present?
          response = RestClient.post response_url, {data: patient.json, token: token}
        end
    driver.quit

    patient.update(response_datetime: Time.now)
    patient.update(request_status: 'Success')
  
    rescue Exception=> e
# <<<<<<< HEAD
      patient.update_attribute('record_available', 'failed')
      puts e.inspect 
      PatientMailer::exception_email("PatientID: #{patient_id} ==> #{e.inspect} \n WebSite = production").deliver
      driver.quit if driver.present?
      patient.update(response_datetime: Time.now)
# =======
      if whether_active == "INACTIVE"
        transaction_date = Time.now.to_datetime.strftime("%d/%m/%y %H:%M %p")
        @json = [{'General' => {'ELIGIBILITY AS OF' => "", 'ELIGIBILITY STATUS' => whether_active, 'TRANSACTION DATE' => transaction_date}}]
        patient.update_attribute('json', JSON.generate(@json))
        if response_url.present?
          response = RestClient.post response_url, {data: patient.json, token: token}
        end
        patient.update_attribute('record_available', 'complete')
        patient.update(request_status: 'Success')
      else
        patient.update_attribute('record_available', 'failed')
        if response_url.present?
          response = RestClient.post response_url, {error: 'please try again', token: token}
        end
        PatientMailer::exception_email("PatientID: #{patient_id} ==> #{e.inspect} \n WebSite = production").deliver
# >>>>>>> d0562ebaa16f2678971578f1ce9ed69002eb875b
        patient.update(request_status: 'Failed')
      end
        driver.quit if driver.present?
        patient.update(response_datetime: Time.now)
    end
  end

  
end
