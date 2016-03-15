task :cigna_test => :environment do 
  obj = UsersController.new.sign_in('skedia105','Empclaims100', 'https://cignaforhcp.cigna.com/web/secure/chcp/windowmanager#tab-hcp.pg.patientsearch$1')

  driver = obj[:driver]
    
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

  wait.until { driver.find_elements(:class, 'collapseTable').present? }

  page = driver.find_element(:css, 'body').attribute('innerHTML').squish

  driver.quit

  sleep(5)

  page_body = Sanitize.clean( page,
	  :elements => ['div', 'a', 'span', 'table', 'tr', 'td', 'th', 'thead', 'tbody', 'ul', 'li', 'button' ],

	  :attributes => {
	    'button' => ['class'],
	    'a' => ['class']  
	  },

	  :remove_contents => ['script', 'style', 'input', 'span']
	)

 #  path = 'cigna_html.txt'
	# File.open(path, "w+") do |f|
 #  	f.write(page_body)
	# end

  body_to_match = File.read('cigna_html.txt')

  if body_to_match == page_body
    UserMailer::HTML_validation_notification("CIGNA is OK").deliver
  	
  else
    UserMailer::HTML_validation_notification("Incosistency has been found in the layout of CIGNA").deliver
  end
end


task :mhnet_test => :environment do 
  obj = UsersController.new.sign_in('ka2002pa','Pcc63128', 'https://www.mhnetprovider.com/')

  driver = obj[:driver]
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
  
  driver.quit
  
  sleep(5)

  page_body = Sanitize.clean( page,
	  :elements => ['div', 'a', 'span', 'table', 'tr', 'td', 'th', 'thead', 'tbody', 'ul', 'li', 'input', 'button' ],

	  :attributes => {
	    'input' => ['class', 'name'],
	    'button' => ['class'],
	    'a' => ['class']  
	  },

	  :remove_contents => ['script', 'style', 'p']
	)

 #  path = 'mhnet_html.txt'
	# File.open(path, "w+") do |f|
 #  	f.write(page_body)
	# end

  body_to_match = File.read('mhnet_html.txt')

  if body_to_match == page_body
    UserMailer::HTML_validation_notification("MHNET Provider is OK").deliver

  else
    UserMailer::HTML_validation_notification("Incosistency has been found in the layout of MHNET Provider").deliver
  end
end
	
task :web_html_test => [:cigna_test, :mhnet_test]  