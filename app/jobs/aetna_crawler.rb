class AetnaCrawler < Struct.new(:site_url)


	def perform
    puts "aa gya"
    driver = Selenium::WebDriver.for :firefox#phantomjs, :args => ['--ignore-ssl-errors=true']
    driver.navigate.to site_url
    puts site_url
    sleep(7)
    un = driver.find_element(:css, "#LoginPortletUsername")
    puts "un field found"
    pw = driver.find_element(:css, "#LoginPortletPassword")
    puts "pw field found"
    un.send_keys "skedia15"
    pw.send_keys "Empclaims$102"
    btn = driver.find_element(:css, "#btnSignInSubmit")
    btn.submit

    puts "sigin done"

    sleep(4)
    driver.navigate.to "https://navinet.navimedix.com/insurers/aetna/eligibility/eligibility-benefits-inquiry?start"
    sleep(15)
    driver.switch_to.frame('appContent')

    dropdown_list = driver.find_elements(:class, 'HandleSelectChange').first
    puts "3"
    options = dropdown_list.find_elements(tag_name: 'option')

    options.each { |option| option.click if option.text.include? 'Ahmad, Ijaz' }

    inp = driver.find_element(:name, 'DISPLAY_MemberID')
    inp.send_keys "W143459914"
    puts "4"
    #inp = driver.find_element(:name, 'DISPLAY_DateOfService')
    #inp.send_keys "8/24/1966"

    btn =  driver.find_element(:class , 'ButtonPrimaryAction')
    puts "5"
    btn.submit

    puts driver.find_element(:tag_name,'body').attribute("innerHTML")

       
    # parsing
    tables = driver.find_elements(:tag_name, 'table')

    member_info = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[2].attribute('innerHTML'),nil,Mechanize.new)

    subscriber_info = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[5].attribute('innerHTML'),nil,Mechanize.new)

    benefit_info = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[7].attribute('innerHTML'),nil,Mechanize.new)

    if member_info.search('.clsEmphasized').first.text.squish == "Member Information"
      
      field_labels = member_info.search('.FieldLabel')
      field_data = member_info.search('.FieldData')

        ar = []
        indexes = []
        
        flag = true
        
        field_labels.each_with_index {|fl,index|
        
          if fl.text != " " && fl.text.present? && (flag || fl.text != "Address:")
            flag = false if fl.text == "Address:"
            ar << { fl.text => field_data[index].text.squish }
          
          elsif fl.text== " "
              indexes << index
          
          end
          
        }
        ar = ar.reduce({},:merge)

        ar["Address:"] = ar["Address:"]+", #{field_data[3].text.squish}"

    elsif subscriber_info.search('.clsEmphasized').first.text.squish == "Subscriber/Group Information"
        field_labels = subscriber_info.search('.FieldLabel')
        field_data = subscriber_info.search('.FieldData')

    end


  end
end
