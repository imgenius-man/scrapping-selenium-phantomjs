class MhnetCrawler < Struct.new(:patntid,:patient_id, :username, :pass, :token, :site_url, :response_url)

	def perform
    begin
       
      puts "patntid: #{patntid}"
      puts "patient_id: #{patient_id}"
      puts "username: #{username}"
      puts "pass #{pass}"
      puts "token #{token}"
      puts "site_url: #{site_url}"
      puts "response_url: #{response_url}"
  

      patient = Patient.find(patntid)
      patient.update(website: 'MHNET')
      patient.update(request_id: 'Req'+patient.id.to_s)
      patient.update(request_datetime: Time.now)
      patient.update(response_id: token)

      
      obj = PatientsController.new.sign_in(username, pass, site_url)

      driver = obj[:driver]

      wait = obj[:wait]
      wait = Selenium::WebDriver::Wait.new(timeout: 20)

      btn_click = driver.find_elements(:css, '.bea-portal-book-primary-menu-single > li')
      btn_click[6].click
      # driver.navigate.to 'https://www.mhnetprovider.com:443/providerPortalWeb/appmanager/mhnet/extPatients?_nfpb=true&_pageLabel=eligibility_page_1_mhnet'

      member_id = driver.find_element(:id, 'mem_id')
      member_id.send_keys patient_id

      service_type = driver.find_element(:id, 'serviceDateStart_memberIdSearch')

      date = 7.days.from_now.strftime("%m/%d/%Y")
      driver.execute_script("$('#serviceDateStart_memberIdSearch').val('#{date}')")

      btn_click = driver.find_element(:name, 'singleMemberSubmit')
      btn_click.click


      wait.until { driver.find_element(:class, 'pcpHistory').displayed? }

      driver.find_element(:class, 'pcpHistory').click

      pcpHistory = driver.find_element(:class, 'fetched').attribute('innerHTML')

      wait.until { driver.find_element(:class, 'coverageHistory').displayed? }

      driver.find_element(:class, 'coverageHistory').click

      cvrgHistory = driver.find_element(:class, 'fetched').attribute('innerHTML')

      wait.until { driver.find_element(:class, 'cobInformation').displayed? }

      driver.find_element(:class, 'cobInformation').click

      cobInformation = driver.find_element(:class, 'fetched').attribute('innerHTML')

      open_tables = driver.find_elements(:class, 'information')

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
          puts "---"*100
          puts address.inspect

          zip = []
          state = []

          address.each_with_index do |v,i|
            if v.to_i != 0
              zip << v
              state << i
            end
          end
          puts "==="*100
          puts zip.inspect
          puts state.inspect

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

            puts "---"*100
            puts cob_info

          else
            cob_info = {'Additional notes' =>  cobInformation.squish.split(/[<p>,<\/p>]/).last}
          end

          cob_table_json = { "Primary Care Physician Information - COB Information" => cob_info}
          @json << cob_table_json
        end
      end

      
      a = []

      @json.each_with_index{|v,i| a << i if v['PLAN LEVEL BENEFITS'].present?}

      if a.count == 2
        @json[a.last]['PLAN LEVEL BENEFITS']['COPAY (TYPE)- IN NETWORK'] = @json[a.first]['PLAN LEVEL BENEFITS']['COPAY (TYPE)- IN NETWORK']
        @json[a.last]['PLAN LEVEL BENEFITS']['ADDITIONAL NOTES'] = @json[a.first]['PLAN LEVEL BENEFITS']['ADDITIONAL NOTES']
        @json[a.last]['PLAN LEVEL BENEFITS']['CODE'] = ''
        @json.delete_at(a.first)
      end

      service_types = Status.find_by_site_url('https://www.mhnetprovider.com/').service_types
        # kcount = 0
          @json.each_with_index do |table_name, index|

            service_types.each do |serv_type|
              if @json[index].present?
                if @json[index][table_name.keys.first].present? && table_name.present? && serv_type.present? && serv_type.type_name.upcase.gsub(/[-\s+*]/, '') == table_name.keys.first.upcase.gsub(/[-\s+*]/, '').tr(',','')
                  serv_type.mapped_service=true
                  # serv_type.save!

                  @json[index][table_name.keys.first]['CODE'] = serv_type.type_code.to_s
                else
                  key = @json[index]
                  a = nil
                  a = Status.find_by_site_url('https://www.mhnetprovider.com/').service_types && ServiceType.find_by_type_name(key.first[0].tr(',',''))
                  if !a.present?
                    b = ServiceType.new
                    b.status_id = Status.find_by_site_url("https://www.mhnetprovider.com/").id
                    b.type_name = key.first[0].tr(',','')
                    # puts "++"*83
                    # puts b.type_name
                    b.mapped_service = true
                    b.save!
                  end
                end
              end
            end
          end
          # puts "-=-=="*82
          # puts kcount
        if service_types.count == 0
          @json.each do |key,val|
            a = nil
            a = Status.find_by_site_url('https://www.mhnetprovider.com/').service_types && ServiceType.find_by_type_name(key.first[0].tr(',',''))
            if !a.present?
              # puts key.first[0]
              b = ServiceType.new
              b.status_id = Status.find_by_site_url("https://www.mhnetprovider.com/").id
              b.type_name = key.first[0].tr(',','')
              b.mapped_service = true
              b.save!
            end
          end

        end

      patient.update_attribute('record_available', 'complete')
      
      patient.update_attribute('json', JSON.generate(@json))

      driver.quit

      if response_url.present?
        response = RestClient.post response_url, {data: JSON.generate(@json), token: token}
        
      end
      patient.update(response_datetime: Time.now)
        patient.update(request_status: 'Success')

    rescue Exception=> e
      patient.update_attribute('record_available', 'failed')

      driver.quit if driver.present?

      PatientMailer::exception_email("PatientID(#{patient.try(:id)}) ==> #{e.inspect} \n WebSite = #{site_url}").deliver

      if response_url.present?
        response = RestClient.post response_url, {error: 'please try again', token: token}
        # patient.update(response_id: 'Req'+patient.id)
        
      end
      patient.update(response_datetime: Time.now)
        patient.update(request_status: 'Failed')
    end
  end


  def parse_table(tbl,key,uper_headers)
  table_hash={}

  rows=tbl.search('tr')

  rows[1..rows.count].map.with_index(1) {|r,n|
    row_data = r.search('td')

    uper_headers[1..uper_headers.length].map.with_index(1) {|upr_hdr,l|
      new_key = key+" - "+row_data.first.text.squish+" - "+upr_hdr

      table_hash[new_key]=row_data[l].text.squish
    }
  }


  table_hash
  end
end
