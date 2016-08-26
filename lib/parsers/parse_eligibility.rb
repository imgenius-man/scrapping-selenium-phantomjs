require 'parsers/parse_table'

class ParseEligibility

	def get_coverage_json(current_array)		
			
		
		headers = current_array['services'].map{|value| value['type_label']} if current_array['services'].present?
		
		json = {}
		# patient detail
		patient_format = ParseTable.new.dummy_array_for_patient_detail
		patient_detail = current_array['demographics']['subscriber']
		
		patient_format['Patient Detail']['Last Name'] = patient_detail['last_name']
		patient_format['Patient Detail']['First Name'] = patient_detail['first_name']
		patient_format['Patient Detail']['Middle Name'] = patient_detail['middle_name']
		patient_format['Patient Detail']['Patient ID'] = patient_detail['member_id']
		patient_format['Patient Detail']['Group No.'] = patient_detail['group_id']
		patient_format['Patient Detail']['Address 1'] = patient_detail['address']['street_line_1']
		patient_format['Patient Detail']['Address 2'] = patient_detail['address']['street_line_2']
		patient_format['Patient Detail']['City'] = patient_detail['address']['city']
		patient_format['Patient Detail']['State'] = patient_detail['address']['state']
		patient_format['Patient Detail']['Zip'] = patient_detail['address']['zip']
		patient_format['Patient Detail']['Gender'] = patient_detail['gender']
		patient_format['Patient Detail']['DOB'] = patient_detail['dob']

		patient_format['Subscriber Detail']['Last Name'] = patient_detail['last_name']
		patient_format['Subscriber Detail']['First Name'] = patient_detail['first_name']
		patient_format['Subscriber Detail']['Middle Name'] = patient_detail['middle_name']
		patient_format['Subscriber Detail']['Patient ID'] = patient_detail['member_id']
		patient_format['Subscriber Detail']['Group No.'] = patient_detail['group_id']
		patient_format['Subscriber Detail']['Address 1'] = patient_detail['address']['street_line_1']
		patient_format['Subscriber Detail']['Address 2'] = patient_detail['address']['street_line_2']
		patient_format['Subscriber Detail']['City'] = patient_detail['address']['city']
		patient_format['Subscriber Detail']['State'] = patient_detail['address']['state']
		patient_format['Subscriber Detail']['Zip'] = patient_detail['address']['zip']
		patient_format['Subscriber Detail']['Gender'] = patient_detail['gender']
		patient_format['Subscriber Detail']['DOB'] = patient_detail['dob']

		plan_detail = current_array['plan']
		
		patient_format['Plan and Network Detail']['Plan Type'] = plan_detail['type']
		patient_format['Plan and Network Detail']['Initial Coverage Date'] = plan_detail['dates'][0]['date_value']
		patient_format['Plan and Network Detail']['Current Coverage From'] = plan_detail['dates'][0]['date_source']
		patient_format['Plan and Network Detail']['Account Name'] = plan_detail['plan_name']
		patient_format['Plan and Network Detail']['Account No.'] = plan_detail['plan_number']

		json = patient_format
		
		json.merge! headers.map { |v|
			{	v => ParseTable.new.dummy_array_for_tables_aetna }
		}.reduce({},:merge)

		current_array['services'].each{|service| 
			header = service['type_label']
			code = service['type']
			if service['financials'].present?
				service['financials'].each{ |finance_key, finance_value|
					# finance_key => coin, ded, 
					finance_value.each{ |type_key, type_value|
						type_value.each { |network_key, network_value|
							network_value.each { |row|
								if finance_key == 'copayment' && row['level'] == 'INDIVIDUAL'
									if network_key == 'in_network' 
										json[header]['COPAY (PER VISIT)- IN NETWORK'] = row['amount']
									elsif network_key == 'out_network'
										json[header]['COPAY (PER VISIT)- OUT OF NETWORK'] = row['amount']
									end
								
								elsif finance_key == 'coinsurance' && row['level'] == 'INDIVIDUAL'
									if network_key == 'in_network' 
										json[header]['COINSURANCE (STANDARD)- IN NETWORK'] = row['percent']
									elsif network_key == 'out_network'
										json[header]['COINSURANCE (STANDARD)- OUT OF NETWORK'] = row['percent']
									end
								
								elsif finance_key == 'deductible'
									if type_key == 'remainings'
										if network_key == 'in_network' && row['level'] == 'FAMILY'
											json[header]['FAMILY DEDUCTIBLE REMAINING - IN NETWORK'] = row['amount']
										elsif network_key == 'out_network' && row['level'] == 'FAMILY'
											json[header]['FAMILY DEDUCTIBLE REMAINING - OUT OF NETWORK'] = row['amount']
										elsif network_key == 'in_network' && row['level'] == 'INDIVIDUAL'
											json[header]['INDIVIDUAL DEDUCTIBLE REMAINING - IN NETWORK'] = row['amount']
										elsif network_key == 'out_network' && row['level'] == 'INDIVIDUAL'
											json[header]['INDIVIDUAL DEDUCTIBLE REMAINING - OUT OF NETWORK'] = row['amount']	
										end
									
									elsif type_key == 'totals'
										if network_key == 'in_network' && row['level'] == 'FAMILY'
											json[header]['FAMILY DEDUCTIBLE AMOUNT- IN NETWORK'] = row['amount']
										elsif network_key == 'out_network' && row['level'] == 'FAMILY'
											json[header]['FAMILY DEDUCTIBLE AMOUNT- OUT OF NETWORK'] = row['amount']
										elsif network_key == 'in_network' && row['level'] == 'INDIVIDUAL'
											json[header]['INDIVIDUAL DEDUCTIBLE AMOUNT- IN NETWORK'] = row['amount']
										elsif network_key == 'out_network' && row['level'] == 'INDIVIDUAL'
											json[header]['INDIVIDUAL DEDUCTIBLE AMOUNT- OUT OF NETWORK'] = row['amount']	
										end	
									
									elsif type_key == 'spent'
										if network_key == 'in_network' && row['level'] == 'FAMILY'
											json[header]['FAMILY DEDUCTIBLE MET- IN NETWORK'] = row['amount']
										elsif network_key == 'out_network' && row['level'] == 'FAMILY'
											json[header]['FAMILY DEDUCTIBLE MET- OUT OF NETWORK'] = row['amount']
										elsif network_key == 'in_network' && row['level'] == 'INDIVIDUAL'
											json[header]['INDIVIDUAL DEDUCTIBLE MET- IN NETWORK'] = row['amount']
										elsif network_key == 'out_network' && row['level'] == 'INDIVIDUAL'
											json[header]['INDIVIDUAL DEDUCTIBLE MET- OUT OF NETWORK'] = row['amount']	
										end		
									end
								end
				}}}}
			end

			json[header]['CODE'] = code
		}
		 
		 json
		 
	end


	def get_medicare_json(current_array)
		json = {}
		# patient detail
		patient_format = ParseTable.new.dummy_array_for_patient_detail
		
		patient_format['Patient Detail']['Last Name'] = current_array['last_name']
		patient_format['Patient Detail']['First Name'] = current_array['first_name']
		patient_format['Patient Detail']['Middle Name'] = current_array['middle_name']
		patient_format['Patient Detail']['Patient ID'] = current_array['member_id']
		patient_format['Patient Detail']['Group No.'] = current_array['group_id']
		patient_format['Patient Detail']['Address 1'] = current_array['address']['street_line_1']
		patient_format['Patient Detail']['Address 2'] = current_array['address']['street_line_2']
		patient_format['Patient Detail']['City'] = current_array['address']['city']
		patient_format['Patient Detail']['State'] = current_array['address']['state']
		patient_format['Patient Detail']['Zip'] = current_array['address']['zip']
		patient_format['Patient Detail']['Gender'] = current_array['gender']
		patient_format['Patient Detail']['DOB'] = current_array['dob']


		# plan_detail = current_array['plan_details'].present? ? current_array['plan_details'] : []
		
		# plan_detail.each { |plan|
		# 	puts "---"*100
		# 	puts plan.inspect
		# 	patient_format['Plan and Network Detail']['Plan Type'] = plan['payer_name']
		# 	patient_format['Plan and Network Detail']['Plan Type'] =  plan['payer_name'].to_s
		# 	patient_format['Plan and Network Detail']['Initial Coverage Date'] = patient_format['Plan and Network Detail']['Initial Coverage Date'].to_s + plan['start_date'].to_s
		# 	patient_format['Plan and Network Detail']['Current Coverage From'] = patient_format['Plan and Network Detail']['Current Coverage From'].to_s + plan['end_date'].to_s
		# 	patient_format['Plan and Network Detail']['Account Name'] = patient_format['Plan and Network Detail']['Account Name'].to_s + plan['payer_name'].to_s
		# }
		

		json = patient_format

		(current_array['requested_service_types'].to_a+current_array['requested_procedure_codes'].to_a).each { |table|
			dummy = ParseTable.new.dummy_array_for_tables_aetna

			dummy['COPAY (PER VISIT)- IN NETWORK'] = table['copayment']
			dummy['COINSURANCE (STANDARD)- IN NETWORK'] = table['coinsurance_percent']
			dummy['INDIVIDUAL DEDUCTIBLE REMAINING - IN NETWORK'] = table['deductible_remaining']
			dummy['INDIVIDUAL DEDUCTIBLE AMOUNT- IN NETWORK'] = table['deductible']

			if table['type_label'].present?
				dummy['CODE'] = table['type']
				json.merge!({ table['type_label'] => dummy })

			elsif table['procedure_label'].present?
				dummy['CODE'] = table['procedure_code']
				json.merge!({ table['procedure_label'] => dummy })
			end
					
		}

		json
	end
end

# (current_array['requested_service_types']+current_array['requested_procedure_codes']).each { |table|
# dummy = ParseTable.new.dummy_array_for_tables_aetna
# dummy['COPAY (PER VISIT)- IN NETWORK'] = table['copayment']
# dummy['COINSURANCE (STANDARD)- IN NETWORK'] = table['coinsurance_percent']
# dummy['INDIVIDUAL DEDUCTIBLE REMAINING - IN NETWORK'] = table['deductible_remaining']
# dummy['INDIVIDUAL DEDUCTIBLE AMOUNT- IN NETWORK'] = table['deductible']
# if table['type_label'].present?
# dummy['CODE'] = table['type']
# json.merge!({ table['type_label'] => dummy })
# elsif table['procedure_label'].present?
# dummy['CODE'] = table['procedure_code']
# json.merge!({ table['procedure_label'] => dummy })
# end
# }