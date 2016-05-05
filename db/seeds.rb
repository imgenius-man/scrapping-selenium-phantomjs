User.create(email: 'admin@goopher.com', password: 'Skedia&&105', password_confirmation: 'Skedia&&105')

Status.create(site_url: 'all', date_checked: Time.now)
Status.create(site_url: 'https://cignaforhcp.cigna.com/',site_username: 'SandyF99',site_password: 'Empclaims100', date_checked: Time.now)
Status.create(site_url: 'https://www.mhnetprovider.com/',site_username: 'ka2002pa',site_password: 'Pcc63128', date_checked: Time.now)
Status.create(site_url: 'https://apps.availity.com/',site_username: 'prospect99',site_password: 'Medicare#20', date_checked: Time.now)

cig = Status.find_by_site_url('https://cignaforhcp.cigna.com/')
test_status_hash = {"Username Field"=> "false","Password Field"=> "false","Login Button"=> "false","Patient Search Button"=> "false","Patient Form"=> "false","Patient ID Field"=> "false","Patient DOB Field"=> "false","Patient Record Search Button"=> "false","Patient Response"=> "false","Table Parsing"=> "false","Excel Generation & Mapping"=> "false","Site Status"=> "false"}
cig.update_attribute('test_status_hash', test_status_hash)

mhnet = Status.find_by_site_url('https://www.mhnetprovider.com/')
test_status_hash = {"Username Field"=> "false","Password Field"=> "false","Login Button"=> "false","Patient Form"=> "false","Patient ID Field"=> "false","Patient Service Date Field"=> "false","Patient Record Search Button"=> "false","Patient Response"=> "false","Patient PCP History Link"=> "false","Patient Coverage History Link"=> "false","Patient CobInformation Link"=> "false","Patient Information Detail"=> "false","Table Parsing"=> "false","Excel Generation & Mapping"=> "false","Site Status"=> "false"}
mhnet.update_attribute('test_status_hash', test_status_hash)

ava = Status.find_by_site_url('https://apps.availity.com/')
test_status_hash = {"Username Field" => "false","Password Field" => "false","Login Button" => "false","Patient Form" => "false","Patient ID Field" => "false","Patient DOB Field" => "false","Patient Payer Id Field" =>"false","Patient Place Of Service Field" => "false","Patient Provider Name Field" => "false","Patient Benefit Field" => "false","Patient Response" => "false","Table Parsing" => "false","Site Status" => "false"}
ava.update_attribute('test_status_hash', test_status_hash)
