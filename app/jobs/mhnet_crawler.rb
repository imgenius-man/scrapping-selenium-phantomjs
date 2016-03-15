class MhnetCrawler < Struct.new(:pat_id, :userid, :pass, :token, :usrid, :site_url)
	

	def perform
    begin
      user = User.find(usrid) 
      
      obj = UsersController.new.sign_in(userid, pass, site_url)
    
      driver = obj[:driver]
      
      wait = obj[:wait]
      wait = Selenium::WebDriver::Wait.new(timeout: 20)

      driver.navigate.to 'https://www.mhnetprovider.com:443/providerPortalWeb/appmanager/mhnet/extUsers?_nfpb=true&_pageLabel=eligibility_page_1_mhnet'
      
      member_id = driver.find_element(:id, 'mem_id')
      member_id.send_keys pat_id

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

            table_json = { table_name[0] => data.reduce({}, :merge)}
          else
            data = [{'Additional notes' => page.at('p').text}]

            table_json = { container_name => data.reduce({}, :merge)}
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
          
          else
            data = {'Additional notes' => html.squish.split(/[<p>,<\/p>]/).last}
          end

          table_json = { container_name => data}
          @json << table_json
        end

        if container_name.include?('Patient Information')
          
          if page.search('h5').present?
            address = page.at('.address').text.squish.split("Address ")
            address=address[1]

            headers = page.search('h5')
            values = page.search('.definition')

            data = headers.map.with_index(0) { |r, i|
              {r.text.squish => values[i].text.squish}
            }.reduce({}, :merge)
          
            data.merge!({'Address' => address})
          else
            data = {'Additional notes' => html.squish.split(/[<p>,<\/p>]/).last}
          end

          table_json = { container_name => data}
          @json << table_json
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

      if @json
          user.update_attribute('record_available', 'complete')
      end
      
      user.update_attribute('json', JSON.generate(@json))

      driver.quit

      response = RestClient.post 'http://statpaymd.net/gopher/scraped_data', {data: JSON.generate(@json), token: token}

      puts "==="*30
      puts response
    rescue Exception=> e
      user.update_attribute('record_available', 'failed')
      
      driver.quit if driver.present?
      
      UserMailer::exception_email("UserID(#{user.try(:id)}) ==> #{e.inspect} \n WebSite = #{site_url}").deliver
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