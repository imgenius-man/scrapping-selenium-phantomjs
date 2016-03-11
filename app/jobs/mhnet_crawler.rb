class MhnetCrawler < Struct.new(:pat_id, :userid, :pass, :token, :usrid, :site_url)
	

	def perform
    begin
      user = User.find(usrid) 
      
      obj = UsersController.new.signin_cigna(userid, pass, site_url)
    
      driver = obj[:driver]
      
      wait = obj[:wait]
      wait = Selenium::WebDriver::Wait.new(timeout: 20)

      driver.navigate.to 'https://www.mhnetprovider.com:443/providerPortalWeb/appmanager/mhnet/extUsers?_nfpb=true&_pageLabel=eligibility_page_1_mhnet'
      
      member_id = driver.find_element(:id, 'mem_id')
      member_id.send_keys pat_id

      service_type = driver.find_element(:id, 'serviceDateStart_memberIdSearch')
      driver.execute_script("$('#serviceDateStart_memberIdSearch').val('03/16/2017')")

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



    rescue Exception=> e
      user.update_attribute('record_available', 'failed')
      puts "77777"*90
      puts user.inspect
      driver.quit if driver.present?
      puts e.inspect
      
      puts "(=Time Out. Please try again later.=)"*90
    end 
  end
end