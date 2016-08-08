require 'parsers/parse_table'

class ParsePokitdok 
	def coverage_json(current_array)
		json = {}
		
		patient = ParseTable.new.dummy_array_for_patient_detail

		patient['Patient Detail']['Patient ID'] = current_array['data']['subscriber']['id']
		patient['Patient Detail']['First Name'] = current_array['data']['subscriber']['first_name']
		patient['Patient Detail']['Last Name'] = current_array['data']['subscriber']['last_name']
		patient['Patient Detail']['DOB'] = current_array['data']['subscriber']['birth_date']
		patient['Patient Detail']['Gender'] = current_array['data']['subscriber']['gender']
		patient['Patient Detail']['City'] = current_array['data']['subscriber']['address']['city']
		patient['Patient Detail']['Zip'] = current_array['data']['subscriber']['address']['zipcode']
		patient['Patient Detail']['State'] = current_array['data']['subscriber']['address']['state']
		patient['Patient Detail']['Address 1'] = current_array['data']['subscriber']['address']['address_lines'].first
		patient['Patient Detail']['Address 2'] = current_array['data']['subscriber']['address']['address_lines'].last
		
		patient['Contacts']['Provider Services'] = current_array['data']['coverage']['contacts'].first['name']
		patient['Contacts']['Claims Address 1'] = current_array['data']['coverage']['contacts'].first['address']['address_lines'].first
		patient['Contacts']['CLAIMS ADDRESS 2'] = current_array['data']['coverage']['contacts'].first['address']['address_lines'].last
		patient['Contacts']['CLAIMS CITY'] = current_array['data']['coverage']['contacts'].first['address']['city']
		patient['Contacts']['CLAIMS STATE'] = current_array['data']['coverage']['contacts'].first['address']['state']
		patient['Contacts']['CLAIMS ZIP'] = current_array['data']['coverage']['contacts'].first['address']['zipcode']

		json.merge! patient
		current_array['data']['service_types'].map{|value| json.merge!({value=>ParseTable.new.dummy_array_for_tables_aetna}) }

		current_array['data']['coverage'].each do |cov_key, coverage|
			if cov_key == 'coinsurance'
				coverage.each do |coinsurance| 
					if coinsurance['in_plan_network'].present? && coinsurance['in_plan_network'] == 'yes' 
						json[coinsurance['service_types'].first]['COINSURANCE (STANDARD)- IN NETWORK'] = coinsurance['benefit_percent']
					
					elsif coinsurance['in_plan_network'].present? && coinsurance['in_plan_network'] == 'no' 
						json[coinsurance['service_types'].first]['COINSURANCE (STANDARD)- OUT OF NETWORK'] = coinsurance['benefit_percent']
					end
				end
			end

			if cov_key == 'copay'
				coverage.each do |copay| 
					if copay['in_plan_network'].present? && copay['in_plan_network'] == 'yes' 
						json[copay['service_types'].first]['COPAY (TYPE)- IN NETWORK'] = copay['copayment']['amount']
				
					elsif copay['in_plan_network'].present? && copay['in_plan_network'] == 'no' 
						json[copay['service_types'].first]['COPAY (TYPE)- OUT OF NETWORK'] = copay['copayment']['amount']
					end
				end
			end

			if cov_key == 'deductibles'
				coverage.each do |deductible|
					if deductible['coverage_level'] == 'family' 
						if deductible['in_plan_network'] == 'yes'
							if deductible['time_period'] == 'calendar_year'
								json[deductible['service_types'].first]['FAMILY DEDUCTIBLE AMOUNT- IN NETWORK'] = deductible['benefit_amount']['amount']
							elsif deductible['time_period'] == 'remaining'
								json[deductible['service_types'].first]['FAMILY DEDUCTIBLE REMAINING - IN NETWORK'] = deductible['benefit_amount']['amount']	
							end
						end

						if deductible['in_plan_network'] == 'no'
							if deductible['time_period'] == 'calendar_year'
								json[deductible['service_types'].first]['FAMILY DEDUCTIBLE AMOUNT- OUT OF NETWORK'] = deductible['benefit_amount']['amount']
							elsif deductible['time_period'] == 'remaining'
								json[deductible['service_types'].first]['FAMILY DEDUCTIBLE REMAINING - OUT OF NETWORK'] = deductible['benefit_amount']['amount']	
							end
						end    
					end

					if deductible['coverage_level'] == 'individual' 
						if deductible['in_plan_network'] == 'yes'
							if deductible['time_period'] == 'calendar_year'
								json[deductible['service_types'].first]['INDIVIDUAL DEDUCTIBLE AMOUNT- IN NETWORK'] = deductible['benefit_amount']['amount']
							elsif deductible['time_period'] == 'remaining'
								json[deductible['service_types'].first]['INDIVIDUAL DEDUCTIBLE REMAINING - IN NETWORK'] = deductible['benefit_amount']['amount']	
							end
						end

						if deductible['in_plan_network'] == 'no'
							if deductible['time_period'] == 'calendar_year'
								json[deductible['service_types'].first]['INDIVIDUAL DEDUCTIBLE AMOUNT- OUT OF NETWORK'] = deductible['benefit_amount']['amount']
							elsif deductible['time_period'] == 'remaining'
								json[deductible['service_types'].first]['INDIVIDUAL DEDUCTIBLE REMAINING - OUT OF NETWORK'] = deductible['benefit_amount']['amount']	
							end
						end    
					end 
				end
			end

			if cov_key == 'out_of_pocket'
				coverage.each do |oop|
					if oop['coverage_level'] == 'family' 
						if oop['in_plan_network'] == 'yes'
							if oop['time_period'] == 'calendar_year'
								json[oop['service_types'].first]['FAMILY OUT OF POCKET MAXIMUM AMOUNT- IN NETWORK'] = oop['benefit_amount']['amount']
							elsif oop['time_period'] == 'remaining'
								json[oop['service_types'].first]['FAMILY OUT OF POCKET MAXIMUM REMAINING - IN NETWORK'] = oop['benefit_amount']['amount']	
							end
						end

						if oop['in_plan_network'] == 'no'
							if oop['time_period'] == 'calendar_year'
								json[oop['service_types'].first]['FAMILY OUT OF POCKET MAXIMUM AMOUNT- OUT OF NETWORK'] = oop['benefit_amount']['amount']
							elsif oop['time_period'] == 'remaining'
								json[oop['service_types'].first]['FAMILY OUT OF POCKET MAXIMUM REMAINING - OUT OF NETWORK'] = oop['benefit_amount']['amount']	
							end
						end    
					end

					if oop['coverage_level'] == 'individual' 
						if oop['in_plan_network'] == 'yes'
							if oop['time_period'] == 'calendar_year'
								json[oop['service_types'].first]['INDIVIDUAL OUT OF POCKET MAXIMUM AMOUNT- IN NETWORK'] = oop['benefit_amount']['amount']
							elsif oop['time_period'] == 'remaining'
								json[oop['service_types'].first]['INDIVIDUAL OUT OF POCKET MAXIMUM REMAINING - IN NETWORK'] = oop['benefit_amount']['amount']	
							end
						end

						if oop['in_plan_network'] == 'no'
							if oop['time_period'] == 'calendar_year'
								json[oop['service_types'].first]['INDIVIDUAL OUT OF POCKET MAXIMUM AMOUNT- OUT OF NETWORK'] = oop['benefit_amount']['amount']
							elsif oop['time_period'] == 'remaining'
								json[oop['service_types'].first]['INDIVIDUAL OUT OF POCKET MAXIMUM REMAINING - OUT OF NETWORK'] = oop['benefit_amount']['amount']	
							end
						end    
					end 
				end
			end
		end
	return json

	end


end

# require 'pokitdok'
# require 'parsers/parse_table'

# pd = PokitDok::PokitDok.new("dZFVMt1fWkbw0gvEFsNd", "4Qvhj8vpmrkJZsFk4OCr12IGK2Oc2XEKkPS3XgcX")

# @eligibility_query = {
# member: {
# birth_date: '1970-01-01',
# first_name: 'Jane',
# last_name: 'Doe',
# id: 'W000000000'
# },
# service_types: ['health_benefit_plan_coverage'],
# trading_partner_id: 'MOCKPAYER'
# }

# current_array = pd.eligibility @eligibility_query
# json = {}

# patient = ParseTable.new.dummy_array_for_patient_detail

# patient['Patient Detail']['Patient ID'] = current_array['data']['subscriber']['id']
# patient['Patient Detail']['First Name'] = current_array['data']['subscriber']['first_name']
# patient['Patient Detail']['Last Name'] = current_array['data']['subscriber']['last_name']
# patient['Patient Detail']['DOB'] = current_array['data']['subscriber']['birth_date']
# patient['Patient Detail']['Gender'] = current_array['data']['subscriber']['gender']
# patient['Patient Detail']['City'] = current_array['data']['subscriber']['address']['city']
# patient['Patient Detail']['Zip'] = current_array['data']['subscriber']['address']['zipcode']
# patient['Patient Detail']['State'] = current_array['data']['subscriber']['address']['state']
# patient['Patient Detail']['Address 1'] = current_array['data']['subscriber']['address']['address_lines'].first
# patient['Patient Detail']['Address 2'] = current_array['data']['subscriber']['address']['address_lines'].last

# patient['Contacts']['Provider Services'] = current_array['data']['coverage']['contacts'].first['name']
# patient['Contacts']['Claims Address 1'] = current_array['data']['coverage']['contacts'].first['address']['address_lines'].first
# patient['Contacts']['CLAIMS ADDRESS 2'] = current_array['data']['coverage']['contacts'].first['address']['address_lines'].last
# patient['Contacts']['CLAIMS CITY'] = current_array['data']['coverage']['contacts'].first['address']['city']
# patient['Contacts']['CLAIMS STATE'] = current_array['data']['coverage']['contacts'].first['address']['state']
# patient['Contacts']['CLAIMS ZIP'] = current_array['data']['coverage']['contacts'].first['address']['zipcode']

# json.merge! patient
# current_array['data']['service_types'].map{|value| json.merge!({value=>ParseTable.new.dummy_array_for_tables_aetna}) }

# current_array['data']['coverage'].each do |cov_key, coverage|
# if cov_key == 'coinsurance'
# coverage.each do |coinsurance| 
# if coinsurance['in_plan_network'].present? && coinsurance['in_plan_network'] == 'yes' 
# json[coinsurance['service_types'].first]['COINSURANCE (STANDARD)- IN NETWORK'] = coinsurance['benefit_percent']

# elsif coinsurance['in_plan_network'].present? && coinsurance['in_plan_network'] == 'no' 
# json[coinsurance['service_types'].first]['COINSURANCE (STANDARD)- OUT OF NETWORK'] = coinsurance['benefit_percent']
# end
# end
# end

# if cov_key == 'copay'
# coverage.each do |copay| 
# if copay['in_plan_network'].present? && copay['in_plan_network'] == 'yes' 
# json[copay['service_types'].first]['COPAY (TYPE)- IN NETWORK'] = copay['copayment']['amount']

# elsif copay['in_plan_network'].present? && copay['in_plan_network'] == 'no' 
# json[copay['service_types'].first]['COPAY (TYPE)- OUT OF NETWORK'] = copay['copayment']['amount']
# end
# end
# end

# if cov_key == 'deductibles'
# coverage.each do |deductible|
# if deductible['coverage_level'] == 'family' 
# if deductible['in_plan_network'] == 'yes'
# if deductible['time_period'] == 'calendar_year'
# json[deductible['service_types'].first]['FAMILY DEDUCTIBLE AMOUNT- IN NETWORK'] = deductible['benefit_amount']['amount']
# elsif deductible['time_period'] == 'remaining'
# json[deductible['service_types'].first]['FAMILY DEDUCTIBLE REMAINING - IN NETWORK'] = deductible['benefit_amount']['amount']	
# end
# end

# if deductible['in_plan_network'] == 'no'
# if deductible['time_period'] == 'calendar_year'
# json[deductible['service_types'].first]['FAMILY DEDUCTIBLE AMOUNT- OUT OF NETWORK'] = deductible['benefit_amount']['amount']
# elsif deductible['time_period'] == 'remaining'
# json[deductible['service_types'].first]['FAMILY DEDUCTIBLE REMAINING - OUT OF NETWORK'] = deductible['benefit_amount']['amount']	
# end
# end    
# end

# if deductible['coverage_level'] == 'individual' 
# if deductible['in_plan_network'] == 'yes'
# if deductible['time_period'] == 'calendar_year'
# json[deductible['service_types'].first]['INDIVIDUAL DEDUCTIBLE AMOUNT- IN NETWORK'] = deductible['benefit_amount']['amount']
# elsif deductible['time_period'] == 'remaining'
# json[deductible['service_types'].first]['INDIVIDUAL DEDUCTIBLE REMAINING - IN NETWORK'] = deductible['benefit_amount']['amount']	
# end
# end

# if deductible['in_plan_network'] == 'no'
# if deductible['time_period'] == 'calendar_year'
# json[deductible['service_types'].first]['INDIVIDUAL DEDUCTIBLE AMOUNT- OUT OF NETWORK'] = deductible['benefit_amount']['amount']
# elsif deductible['time_period'] == 'remaining'
# json[deductible['service_types'].first]['INDIVIDUAL DEDUCTIBLE REMAINING - OUT OF NETWORK'] = deductible['benefit_amount']['amount']	
# end
# end    
# end 
# end
# end

# if cov_key == 'out_of_pocket'
# coverage.each do |oop|
# if oop['coverage_level'] == 'family' 
# if oop['in_plan_network'] == 'yes'
# if oop['time_period'] == 'calendar_year'
# json[oop['service_types'].first]['FAMILY OUT OF POCKET MAXIMUM AMOUNT- IN NETWORK'] = oop['benefit_amount']['amount']
# elsif oop['time_period'] == 'remaining'
# json[oop['service_types'].first]['FAMILY OUT OF POCKET MAXIMUM REMAINING - IN NETWORK'] = oop['benefit_amount']['amount']	
# end
# end

# if oop['in_plan_network'] == 'no'
# if oop['time_period'] == 'calendar_year'
# json[oop['service_types'].first]['FAMILY OUT OF POCKET MAXIMUM AMOUNT- OUT OF NETWORK'] = oop['benefit_amount']['amount']
# elsif oop['time_period'] == 'remaining'
# json[oop['service_types'].first]['FAMILY OUT OF POCKET MAXIMUM REMAINING - OUT OF NETWORK'] = oop['benefit_amount']['amount']	
# end
# end    
# end

# if oop['coverage_level'] == 'individual' 
# if oop['in_plan_network'] == 'yes'
# if oop['time_period'] == 'calendar_year'
# json[oop['service_types'].first]['INDIVIDUAL OUT OF POCKET MAXIMUM AMOUNT- IN NETWORK'] = oop['benefit_amount']['amount']
# elsif oop['time_period'] == 'remaining'
# json[oop['service_types'].first]['INDIVIDUAL OUT OF POCKET MAXIMUM REMAINING - IN NETWORK'] = oop['benefit_amount']['amount']	
# end
# end

# if oop['in_plan_network'] == 'no'
# if oop['time_period'] == 'calendar_year'
# json[oop['service_types'].first]['INDIVIDUAL OUT OF POCKET MAXIMUM AMOUNT- OUT OF NETWORK'] = oop['benefit_amount']['amount']
# elsif oop['time_period'] == 'remaining'
# json[oop['service_types'].first]['INDIVIDUAL OUT OF POCKET MAXIMUM REMAINING - OUT OF NETWORK'] = oop['benefit_amount']['amount']	
# end
# end    
# end 
# end
# end
# end
# a = Patient.last
# a.record_available = 'complete'
# a.json = [json].to_json
# a.save