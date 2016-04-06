 task :cigna_test => :environment do
  cig = Status.find_by_site_url("https://cignaforhcp.cigna.com/")
  begin
    if !cig
      cig = Patient.new
      cig.site_url = "https://cignaforhcp.cigna.com/"
      cig.save!
    end
    obj = PatientsController.new.sign_in('SandyF99','Empclaims100', 'https://cignaforhcp.cigna.com/web/secure/chcp/windowmanager#tab-hcp.pg.patientsearch$1')
    driver = obj[:driver]
    cig.login_status = true
  rescue Exception=>e
    cig.login_status = false
    cig.patient_search_status = false
    cig.site_status = false
    cig.status = false
    PatientMailer::HTML_validation_notification("Login failed of CIGNA").deliver
  end

  begin
    cig.date_checked= DateTime.now
    cig.save!
    wait = obj[:wait]

    href_search = ''
    wait.until {
      href_search = driver.find_elements(:class,'patients')[1]
    }
    href_search.click

    member_id = nil
    wait.until {
      member_id = driver.find_element(:name, 'memberDataList[0].memberId')
    }

    member_id.send_keys 'U5151043002'

    dob = driver.find_element(:name, 'memberDataList[0].dobDate')
    dob.send_keys '15/06/1986'

    ee = driver.find_elements(:class,'btn-submit-form-patient-search')[0]
    ee.submit


    sleep(2)

    driver.find_elements(:class,'btn-submit-form-patient-search')[0]

    link = nil

    wait.until {
      link = driver.find_elements(:css,'.patient-search-result-table > tbody > tr > td > .oep-managed-link')[0]
    }
    link.click
    cig.patient_search_status = true
  rescue Exception=>e
    cig.patient_search_status = false
    cig.site_status = false
    cig.status = false
    PatientMailer::HTML_validation_notification("Failed: Patient Search -- CIGNA").deliver
  end

  begin
    cig.save!
    
    eligibility_status = driver.find_elements(:css,'.patient-search-result-table > tbody > tr > td')[7].attribute('innerHTML')
        
    transaction_date = Time.now.to_datetime.strftime("%d/%m/%y %H:%M %p")
        
    date_of_eligibility = driver.find_element(:css, '.patient-results-onDate > span').attribute('innerHTML')

    patient_flag = false

    wait.until { driver.find_elements(:class, 'collapseTable').present? }

    sleep(2)

    if driver.find_elements( :class,"oep-managed-sub-tab").second.displayed?
      driver.find_elements( :class,"oep-managed-sub-tab").second.click
    end

    sleep(4)

    wait.until { driver.find_elements(:class, 'collapseTable').present? }


    containers = driver.find_elements(:class, 'collapseTable-container')

    @json = Patient.parse_containers(containers, date_of_eligibility, eligibility_status, transaction_date)

    driver.quit

    cig.site_status = true
    
  rescue Exception=>e
    cig.site_status = false

    PatientMailer::HTML_validation_notification("Failed: Table parsing into JSON -- CIGNA").deliver
  end


  #=======================================================
  begin
   cig.save!

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

    cig.status = true
    cig.save!
    PatientMailer::HTML_validation_notification("CIGNA is Working").deliver
      
  rescue Exception => e
    cig.status = false
    cig.save!
    
    PatientMailer::HTML_validation_notification("Failed: Excel generation and mapping -- CIGNA").deliver
  end

end


task :mhnet_test => :environment do
  mhnet = Status.find_by_site_url("https://www.mhnetprovider.com/")
  begin
    obj = PatientsController.new.sign_in('ka2002pa','Pcc63128', 'https://www.mhnetprovider.com/')
    driver = obj[:driver]
    mhnet.login_status = true
  rescue Exception=>e
    mhnet.login_status = false
    mhnet.patient_search_status = false
    mhnet.site_status = false
    mhnet.status = false
    PatientMailer::HTML_validation_notification("Login failed of MHNET").deliver
  end

  begin
    mhnet.date_checked= DateTime.now
    mhnet.save!
    wait = obj[:wait]

    driver.navigate.to 'https://www.mhnetprovider.com:443/providerPortalWeb/appmanager/mhnet/extUsers?_nfpb=true&_pageLabel=eligibility_page_1_mhnet'
    member_id = driver.find_element(:id, 'mem_id')
    member_id.send_keys '90261149003'

    service_type = driver.find_element(:id, 'serviceDateStart_memberIdSearch')

    date = 7.days.from_now.strftime("%m/%d/%Y")
    driver.execute_script("$('#serviceDateStart_memberIdSearch').val('#{date}')")

    btn_click = driver.find_element(:name, 'singleMemberSubmit')
    btn_click.click

    page = driver.find_element(:css, 'body').attribute('innerHTML').squish
    mhnet.patient_search_status = true
  rescue Exception=>e
    mhnet.patient_search_status = false
    mhnet.site_status = false
    mhnet.status = false
    PatientMailer::HTML_validation_notification("Patient Search failed of MHNET").deliver
  end

  begin
    driver.quit

    sleep(5)

    page_body = Sanitize.clean( page,
      :elements => ['div', 'span', 'table', 'tr', 'td', 'th', 'thead', 'tbody', 'ul', 'li', 'input', 'button' ],

      :attributes => {
        'input' => ['class', 'name'],
        'button' => ['class'],
        'a' => ['class']
      },

      :remove_contents => ['script', 'style', 'p', 'a']
    )

    body_to_match = File.read('mhnet_html.txt')

    if body_to_match == page_body
      mhnet.status = true
      mhnet.site_status = true
      PatientMailer::HTML_validation_notification("MHNET Provider is OK").deliver

    else
      mhnet.status = false
      mhnet.site_status = false
      PatientMailer::HTML_validation_notification("Inconsistency has been found in the layout of MHNET Provider").deliver
    end
    mhnet.save!
  rescue Exception=>e
    PatientMailer::HTML_validation_notification("Exception: Inconsistency has been found in the layout of MHNET Provider").deliver
  end

end

task :web_html_test => [:cigna_test, :mhnet_test]
