# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
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

# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_username_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_password_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_login_submission_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_patient_search_page_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_patient_search_button_click_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_patient_form_visibility_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_patient_ID_field_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_patient_DOB_field_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_patient_last_name_field_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_patient_first_name_field_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_patient_form_submission_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_patient_form_response_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_table_parsing_test", status_result: false)
# TestCaseStatus.create(site_id: status_site_id, status_name: "cigna_excel_generation_test", status_result: false)



    
