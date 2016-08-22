require 'parsers/parse_eligibility'
class EligibilityApi
	def send(params)
		params = {
			:api_key=>"TneErbrxyRnO1M1q4G8zrvqzArl79mugZSHW", 
			:payer_id=>params['payer_id'], :provider_npi=>params['p_npi'], 
			:provider_first_name=>params['p_first_name'], 
			:provider_last_name=>params['p_last_name'], :member_id=>params['ins_id'], :member_first_name=>params['first_name'], :member_last_name=>params['last_name'], :member_dob=>params['dob'], :service_type=>params['service_type'], :procedure_code=>params['procedure_code'], :multiple_stc=>true} 
		current_json_string = RestClient.get("https://gds.eligibleapi.com/v1.4/coverage/all.json", params: params)
		current_array = JSON.parse(current_json_string)
		return ParseEligibility.new.get_coverage_json(current_array)
	end

	def service_type_codes
		{
	'Occupational Therapy' => 'AD',
	'Physical Medicine' => 'AE',
	'Speech Therapy' => 'AF',
	'Skilled Nursing Care' => 'AG',
	'Pulmonary Rehabilitation' => 'BF',
	'Cardiac Rehabilitation' => 'BG',
	'Blood Charges (Deductible)' => '10',
	'End Stage Renal - Renal Supplies in the Home' => '14',
	'End Stage Renal - Alternate Method Dialysis' => '15',
	'Home Health Care' => '42',
	'Hospice' => '45',
	'Hospital' => '47',
	'Hospital - Inpatient' => '48',
	'Hospital - Room and Board' => '49',
	'Smoking Cessation' => '67',
		}

	end

	def procedure_codes
		{

	'Screening Mammography (MAMM)' => '77057',
	'Cardiovascular Disease Screening (CARD)' => '80061',
	'Fecal Occult Blood Test (FOBT)' => '82270',
	'Cardiovascular Disease Screening (CARD)' => '82465',
	'Diabetes Screening Tests (DIAB)' => '82947',
	'Diabetes Screening Tests (DIAB)' => '82950',
	'Diabetes Screening Tests (DIAB)' => '82951',
	'Cardiovascular Disease Screening (CARD)' => '83718',
	'Cardiovascular Disease Screening (CARD)' => '84478',
	'Pneumococcal Vaccine (PPV)' => '90669',
	'Pneumococcal Vaccine (PPV)' => '90670',
	'Pneumococcal Vaccine (PPV)' => '90732',
	'Screening Pelvic Exam (PCBE)' => 'G0101',
	'Prostate Cancer Screening (PROS) i' => 'G0102',
	'Prostate Cancer Screening (PROS) i' => 'G0103',
	'Colorectal Cancer Screening (COLO)' => 'G0104',
	'Colorectal Cancer Screening (COLO)' => 'G0105',
	'Colorectal Cancer Screening (COLO)' => 'G0106',
	'Glaucoma Screening (GLAU)' => 'G0117',
	'Glaucoma Screening (GLAU)' => 'G0118',
	'Colorectal Cancer Screening (COLO)' => 'G0120',
	'Colorectal Cancer Screening (COLO)' => 'G0121',
	'Screening Pap Test (PAPT)' => 'G0123',
	'Screening Pap Test (PAPT)' => 'G0143',
	'Screening Pap Test (PAPT)' => 'G0144',
	'Screening Pap Test (PAPT)' => 'G0145',
	'Screening Pap Test (PAPT)' => 'G0147',
	'Screening Pap Test (PAPT)' => 'G0148',
	'Screening Mammography (MAMM)' => 'G0202',
	'Fecal Occult Blood Test (FOBT)' => 'G0328',
	'Ultrasound Screening for Abdominal Aortic Aneurysm (AAA)' => 'G0389',
	'Initial Preventive Physical Examination (IPPE)' => 'G0402',
	'Initial Preventive Physical Examination (IPPE)' => 'G0403',
	'Initial Preventive Physical Examination (IPPE)' => 'G0404',
	'Initial Preventive Physical Examination (IPPE)' => 'G0405',
	'Annual Wellness Visit (AWV)' => 'G0438',
	'Annual Wellness Visit (AWV)' => 'G0439',
	'Annual Depression Screening' => 'G0444',
	'Screening and High Intensive Behavioral Counseling (HIBC) to prevent STIs' => 'G0445',
	'Intensive Behavioral Therapy (IBT) for Cardiovascular Disease (CVD)' => 'G0446',
	'Intensive Behavioral Counseling for Obesity' => 'G0447',
	'Screening Pap Test (PAPT)' => 'P3000',
	'Screening Pap Test (PAPT)' => 'Q0091',
		}
	end
end
# params = {
# :api_key=>"TneErbrxyRnO1M1q4G8zrvqzArl79mugZSHW", 
# :payer_id=>"ILBLS", :provider_npi=>"1881868669", 
# :provider_first_name=>"Andy", 
# :provider_last_name=>"Stroud", :member_id=>"XOF823201728", :member_first_name=>"Howard", :member_last_name=>"Goldsmith", :member_dob=>"1989-10-17", :service_type=>"98", :procedure_code=>'84478', :multiple_stc=>true} 

# http://screencast.com/t/yI7Z5NJed
