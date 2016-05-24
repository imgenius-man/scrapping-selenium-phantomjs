class ParseTable


	def json_table(table_content, table_name, head_count, additional_info, container_info)
		if head_count == 0
			parse_0H_table(table_content, table_name, head_count, additional_info, container_info)

		elsif head_count == 1
			parse_1H_table(table_content, table_name, head_count, additional_info)

		elsif head_count == 2
			parse_2H_table(table_content, table_name, head_count, additional_info)
		end
	end


	def merge_arrays(dummy_array, data_array)
		temp = dummy_array.map{|k,v| {k.upcase.gsub(/[-\s+*]/, '') => ''}}.reduce({},:merge)

		data_array.each{|k,v|
			if k.upcase.gsub(/[-\s+*]/,'') == "COINSURANCEAMOUNTINNETWORK"
				temp["COINSURANCE(STANDARD)INNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "COINSURANCEAMOUNTOUTOFNETWORK"
				temp["COINSURANCE(STANDARD)OUTOFNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "COINSURANCE(SPECIAL)AMOUNTOUTOFNETWORK"
				temp["COINSURANCE(SPECIAL)OUTOFNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "COINSURANCE(SPECIAL)AMOUNTINNETWORK"
				temp["COINSURANCE(SPECIAL)INNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "MAXIMUM$(PERCALENDARYEAR)AMOUNTINNETWORK" || k.upcase.gsub(/[-\s+*]/,'') == "DEDUCTIBLEDOLLARSINNETWORKYEARLYCONTRACTLIMITINDIVIDUAL"
				temp["INDIVIDUALDEDUCTIBLEAMOUNTINNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "DEDUCTIBLEDOLLARSINNETWORKYEARLYCONTRACTLIMITFAMILY"
				temp["FAMILYDEDUCTIBLEAMOUNTINNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "DEDUCTIBLEDOLLARSOUTOFNETWORKYEARLYCONTRACTLIMITFAMILY"
				temp["FAMILYDEDUCTIBLEAMOUNTOUTOFNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "MAXIMUM$(PERCALENDARYEAR)AMOUNTOUTOFNETWORK" || k.upcase.gsub(/[-\s+*]/,'') == "DEDUCTIBLEDOLLARSOUTOFNETWORKYEARLYCONTRACTLIMITINDIVIDUAL"
				temp["INDIVIDUALDEDUCTIBLEAMOUNTOUTOFNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "COPAYMENT(PERVISIT)AMOUNTINNETWORK"
				temp["COPAY(PERVISIT)INNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "COPAYMENT(PERVISIT)AMOUNTOUTOFNETWORK"
				temp["COPAY(PERVISIT)OUTOFNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "DEDUCTIBLEDOLLARSINNETWORKREMAININGUSAGEINDIVIDUAL"
				temp["INDIVIDUALDEDUCTIBLEREMAININGINNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "DEDUCTIBLEDOLLARSOUTOFNETWORKREMAININGUSAGEINDIVIDUAL"
				temp["INDIVIDUALDEDUCTIBLEREMAININGOUTOFNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "DEDUCTIBLEDOLLARSINNETWORKREMAININGUSAGEFAMILY"
				temp["FAMILYDEDUCTIBLEREMAININGINNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "DEDUCTIBLEDOLLARSOUTOFNETWORKREMAININGUSAGEFAMILY"
				temp["FAMILYDEDUCTIBLEREMAININGOUTOFNETWORK"] = v
			end

			temp[k.upcase.gsub(/[-\s+*]/,'')] = v
		}

		dummy_array.each{ |k,v| dummy_array[k] = temp[k.upcase.gsub(/[-\s+]/,'')]}


		dummy_array
	end

	def dummy_array_for_h2_table_availity
		{
			"CODE"=>"",
			"EFFECTIVE DATE - IN NETWORK"=>"",
			"EFFECTIVE DATE - OUT OF NETWORK"=>"",
			"COPAY (PER VISIT)- IN NETWORK"=>"",
			"COPAY (PER VISIT)- OUT OF NETWORK"=>"",
			"COPAY (TYPE)- IN NETWORK"=>"",
			"COPAY (TYPE)- OUT OF NETWORK"=>"",
			"COINSURANCE (STANDARD)- IN NETWORK"=>"",
			"COINSURANCE (STANDARD)- OUT OF NETWORK"=>"",
			"COINSURANCE (SPECIAL)- IN NETWORK"=>"",
			"COINSURANCE (SPECIAL) - OUT OF NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) AMOUNT- IN NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) MET- IN NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) REMAINING - IN NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) AMOUNT- OUT OF NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) MET- OUT OF NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) REMAINING - OUT OF NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) AMOUNT- IN NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) MET- IN NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) REMAINING - IN NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) AMOUNT- OUT OF NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) MET- OUT OF NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) REMAINING - OUT OF NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE AMOUNT- IN NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE MET- IN NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE REMAINING - IN NETWORK"=>"",
			"FAMILY DEDUCTIBLE AMOUNT- IN NETWORK"=>"",
			"FAMILY DEDUCTIBLE MET- IN NETWORK"=>"",
			"FAMILY DEDUCTIBLE REMAINING - IN NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE AMOUNT- OUT OF NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE MET- OUT OF NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE REMAINING - OUT OF NETWORK"=>"",
			"FAMILY DEDUCTIBLE AMOUNT- OUT OF NETWORK"=>"",
			"FAMILY DEDUCTIBLE MET- OUT OF NETWORK"=>"",
			"FAMILY DEDUCTIBLE REMAINING - OUT OF NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM AMOUNT- IN NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM MET- IN NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM REMAINING - IN NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM AMOUNT- IN NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM MET- IN NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM REMAINING - IN NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM AMOUNT- OUT OF NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM MET- OUT OF NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM REMAINING - OUT OF NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM AMOUNT- OUT OF NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM MET- OUT OF NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM REMAINING - OUT OF NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM AMOUNT- IN NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM MET- IN NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM REMAINING - IN NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM AMOUNT- IN NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM MET- IN NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM REMAINING - IN NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM AMOUNT- OUT OF NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM MET- OUT OF NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM REMAINING - OUT OF NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM AMOUNT- OUT OF NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM MET- OUT OF NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM REMAINING - OUT OF NETWORK"=>"",
			"ADDITIONAL NOTES"=>""
		}
	end

	def dummy_array_for_h2_table
		{
			"CODE"=>"",
			"EFFECTIVE DATE - IN NETWORK"=>"",
			"EFFECTIVE DATE - OUT OF NETWORK"=>"",
			"COPAY (PER VISIT)- IN NETWORK"=>"",
			"COPAY (PER VISIT)- OUT OF NETWORK"=>"",
			"COPAY (TYPE)- IN NETWORK"=>"",
			"COPAY (TYPE)- OUT OF NETWORK"=>"",
			"COINSURANCE (STANDARD)- IN NETWORK"=>"",
			"COINSURANCE (STANDARD)- OUT OF NETWORK"=>"",
			"COINSURANCE (SPECIAL)- IN NETWORK"=>"",
			"COINSURANCE (SPECIAL) - OUT OF NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) AMOUNT- IN NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) MET- IN NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) REMAINING - IN NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) AMOUNT- OUT OF NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) MET- OUT OF NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) REMAINING - OUT OF NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) AMOUNT- IN NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) MET- IN NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) REMAINING - IN NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) AMOUNT- OUT OF NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) MET- OUT OF NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) REMAINING - OUT OF NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE AMOUNT- IN NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE MET- IN NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE REMAINING - IN NETWORK"=>"",
			"FAMILY DEDUCTIBLE AMOUNT- IN NETWORK"=>"",
			"FAMILY DEDUCTIBLE MET- IN NETWORK"=>"",
			"FAMILY DEDUCTIBLE REMAINING - IN NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE AMOUNT- OUT OF NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE MET- OUT OF NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE REMAINING - OUT OF NETWORK"=>"",
			"FAMILY DEDUCTIBLE AMOUNT- OUT OF NETWORK"=>"",
			"FAMILY DEDUCTIBLE MET- OUT OF NETWORK"=>"",
			"FAMILY DEDUCTIBLE REMAINING - OUT OF NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM AMOUNT- IN NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM MET- IN NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM REMAINING - IN NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM AMOUNT- IN NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM MET- IN NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM REMAINING - IN NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM AMOUNT- OUT OF NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM MET- OUT OF NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM REMAINING - OUT OF NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM AMOUNT- OUT OF NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM MET- OUT OF NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM REMAINING - OUT OF NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM AMOUNT- IN NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM MET- IN NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM REMAINING - IN NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM AMOUNT- IN NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM MET- IN NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM REMAINING - IN NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM AMOUNT- OUT OF NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM MET- OUT OF NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM REMAINING - OUT OF NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM AMOUNT- OUT OF NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM MET- OUT OF NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM REMAINING - OUT OF NETWORK"=>"",
			"ADDITIONAL NOTES"=>""
		}
	end


	def dummy_array_for_patient_detail
			{
			"Patient Detail"=>{
				"Patient ID"=>"",
				"Group No."=>"",
				"Prefix"=>"",
				"First Name"=>"",
				"Middle Name"=>"",
				"Last Name"=>"",
				"Suffix"=>"",
				"Gender"=>"",
				"DOB"=>"",
				"Address 1"=>"",
				"Address 2"=>"",
				"City"=>"",
				"State"=>"",
				"Zip"=>"",
				"Relationship to Subscriber"=>"",
				"PHONE NO."=>"",
				"FAX NO."=>"",
				"EMAIL"=>""
				},
			"Subscriber Detail"=>{
				"Prefix"=>"",
				"First Name"=>"",
				"Middle Name"=>"",
				"Last Name"=>"",
				"Gender"=>"",
				"DOB"=>"",
				"Address 1"=>"",
				"Address 2"=>"",
				"City"=>"",
				"State "=>"",
				"Zip"=>"",
				"PHONE NO."=>"",
				"FAX NO."=>"",
				"EMAIL"=>""
				},
			"Plan and Network Detail"=>{
				"Plan Type"=>"",
				"Account Name"=>"",
				"Account No."=>"",
				"Initial Coverage Date"=>"",
				"Current Coverage From"=>"",
				"Current Coverage To"=>"",
				"Other Insurance Verified"=>"",
				"ADDITIONAL NOTES"=>""
				},
			"Contacts"=>{
				"Provider Services"=>"",
				"Member Services"=>"",
				"Claims Address 1"=>"",
				"CLAIMS ADDRESS 2"=>"",
				"CLAIMS CITY"=>"",
				"CLAIMS STATE"=>"",
				"CLAIMS ZIP"=>"",
				"ELECTRONIC CLAIMS"=>"",
				"ADDITIONAL NOTES"=>""
			}
		}

	end

	def dummy_patient_detail
		dummy_array_for_patient_detail["Patient Detail"]
	end

	def dummy_subcriber_detail
		dummy_array_for_patient_detail["Subscriber Detail"]
	end

	def dummy_plan_detail
		dummy_array_for_patient_detail["Plan and Network Detail"]
	end

	def dummy_contact_detail
		dummy_array_for_patient_detail["Contacts"]
	end

	def dummy_plan_provider
		{
		"CARE COORDINATION PROVIDER"=>"",
		"PATIENT ALIGNED PHYSICIAN FIRST NAME"=>"",
		"PATIENT ALIGNED PHYSICIAN MIDDLE NAME"=>"",
		"PATIENT ALIGNED PHYSICIAN LAST NAME"=>"",
		"PATIENT ALIGNED PHYSICIAN NPI"=>"",
		"PATIENT ALIGNED MEDICAL GROUP NAME"=>"",
		"CARE COORDINATION NOTES"=>"",
	  "PHYSICIAN FIRST NAME"=>"",
	  "PHYSICIAN MIDDLE NAME"=>"",
	  "PHYSICIAN LAST NAME"=>"",
	  "PHYSICIAN NPI"=>"",
	  "MEDICAL GROUP NAME"=>"",
		"Address 1"=>"",
		"Address 2"=>"",
		"City"=>"",
		"State"=>"",
		"Zip"=>"",
		"PHONE NO."=>"",
		"FAX NO."=>"",
		"EMAIL"=>""
		}
	end

private
	def map_keys(table_content, head_count, additional_info)
		table_content[head_count..table_content.length].map do |tr|
			tr[:tr][1..tr[:tr].length].map.with_index(1) do |td, i|

				if tr[:tr].length/2 >= i
					network = table_content[0][:tr][1][:th].first.to_s

				elsif tr[:tr].length/2 < i
					if table_content[0][:tr][2].present?
						network = table_content[0][:tr][2][:th].first.to_s

					else
						network = table_content[0][:tr][1][:th].first.to_s
					end
				end

				value = td[:td].inject(&:+).to_s

				if head_count == 2
					key_value_hash_for_2HT(tr, table_content, network, value, i)

				elsif head_count == 1
					key_value_hash_for_1HT(tr, network, value)
				end
			end
		end << {"Additional Notes" => additional_info}
	end


	def map_keys_complex_table(table_content, table_name, head_count)
		header_arrays = []

		row_length = table_content.first[:tr].length

		data_array = []
		notes = []


		(row_length).times do |cell_i|
			if table_name == 'Patient and Plan Detail'
				arr = traverse_table_columnwise(table_content, row_length, cell_i).reject{|b| b.is_a?(String) || b.blank?}
				header_arrays << { table_content.first[:tr][cell_i][:th].first => ( arr.is_a?(String) ? arr : arr.reduce({}, :merge) ) }

			elsif table_name == 'Maternity'

				dummy_array = dummy_array_for_h2_table()

				data_array << { table_content.first[:tr][cell_i][:th].first => traverse_table_columnwise(table_content, row_length, cell_i).inject(&:+) }

				notes << data_array.reduce({}, :merge).map{|k,v| "#{k}-#{v};"}

				strng = notes.inject(&:+)

				dummy_array['ADDITIONAL NOTES'] = strng.inject(&:+)
				dummy_array['CODE'] = ''


				header_arrays << {table_name => dummy_array}
			# else
			# 	header_arrays << { table_content.first[:tr][cell_i][:th].first => traverse_table_columnwise(table_content, row_length, cell_i) }
			end
		end

		header_arrays.reduce({}, :merge)
	end


	def traverse_table_columnwise(table_content, row_length, cell_i)
		array = []

		coulmn_length = table_content.length

		(1..coulmn_length-1).map do |row_i|
			tempry=""

			if table_content[row_i][:tr][cell_i][:td].present? && table_content[row_i][:tr][cell_i][:td].second.present?
				table_content[row_i][:tr][cell_i][:td].each do |a|
					if a != ""
						if a.scan(/:/).count == 0
							tempry=tempry + " " + a

							if tempry.scan(/:/).count != 0
								b = tempry.split(":")

								array[array.length-1] = {b[0].to_s => b[1].to_s}
							end

						else
							tempry = a

							b = tempry.split(":")

							array << {b[0].to_s => b[1].to_s}
						end
					end
				end

			else
				array << table_content[row_i][:tr][cell_i][:td].first
			end
		end
		array
	end


	def key_value_hash_for_2HT(tr, table_content, network, value, i)
		{
			tr[:tr][0][:td].inject(&:+).to_s + " " + table_content[1][:tr][i][:th].inject(&:+).to_s + " - " + network => value
		}
	end


	def key_value_hash_for_1HT(tr, network, value)
		if network.blank? || network.nil?
			{
				tr[:tr][0][:td].inject(&:+).to_s => value
			}

		else
			{
				tr[:tr][0][:td].inject(&:+).to_s + " - " + network => value
			}
		end
	end


	def parse_2H_table(table_content, table_name, head_count, additional_info)
		if table_content[0][:tr][0][:th].first.present?
			dummy_array = dummy_array_for_h2_table()

			data_array = map_keys(table_content, head_count, additional_info).flatten!.reduce({}, :merge)

			filled_array = merge_arrays(dummy_array, data_array)

			if table_name == 'Short Term Rehabilitation/Therapy'
				filled_array["CODE"] = 'SHORT TERM REHABILITATOIN/THERAPY - ZZ03'

			elsif table_name == 'Chiropractic Care'
				filled_array["CODE"] = 'CHIROPRACTIC CARE -33'
			end

			{
				table_name + " - " + table_content[0][:tr][0][:th].inject(&:+).to_s => filled_array
			}

		elsif table_content[0][:tr][0][:th].first.nil?
			dummy_array = dummy_array_for_h2_table()

			data_array = map_keys(table_content, head_count, additional_info).flatten!.reduce({}, :merge)

			final_array = merge_arrays(dummy_array, data_array)

			if table_name == 'Specialist Services'
				final_array["CODE"] = 'Specialist Services- ZZ01'
			end

			{
				table_name => final_array
			}
		end
	end


	def parse_1H_table(table_content, table_name, head_count, additional_info)
		if table_content[0][:tr][0][:th].first.present? && table_content[0][:tr][1].present? && table_content[0][:tr][1][:th].first.to_s.include?('In-Network')
			dummy_array = dummy_array_for_h1_table(table_content)

			data_array = map_keys(table_content, head_count, additional_info).flatten!.reduce({}, :merge)

			filled_array = merge_arrays(dummy_array, data_array)
			filled_array['PROGRAM NAME'] = table_content[0][:tr][0][:th].inject(&:+).to_s

			{
				table_name => filled_array
			}

		elsif (table_content[0][:tr][0][:th].first.blank? || table_content[0][:tr][0][:th].first.nil?)  && table_content[0][:tr][1][:th].first.to_s.include?('In-Network')
			{
				table_name => map_keys(table_content, head_count, additional_info).flatten!.reduce({}, :merge)
			}

		elsif table_content[0][:tr][0][:th].first.present? && table_content[0][:tr][1].present? &&(table_content[0][:tr][1][:th].first.blank? || table_content[0][:tr][1][:th].first.nil?)
			{
				table_name + " - " + table_content[0][:tr][0][:th].first => map_keys(table_content, head_count, additional_info).flatten!.reduce({}, :merge)
			}

		elsif (table_content[0][:tr][0][:th].first.blank? || table_content[0][:tr][0][:th].first.nil?) && table_content[0][:tr][1].present? && (table_content[0][:tr][1][:th].first.blank? || table_content[0][:tr][1][:th].first.nil?)
			dummy_array = dummy_array_for_h1_table(table_content)

			data_array =
				table_content[head_count..table_content.length].map do |tr|
					{tr[:tr][0][:td].inject => tr[:tr][1][:td].inject}
				end.reduce({}, :merge)

			filled_array = merge_arrays(dummy_array, data_array)

			name = data_array['Patient Aligned Physician Name'].split(" ")

			filled_array['CODE'] = ''
			filled_array['CARE COORDINATION PROVIDER'] = data_array['CAC Name']
			filled_array['PATIENT ALIGNED PHYSICIAN FIRST NAME'] = name[0]
			filled_array['PATIENT ALIGNED PHYSICIAN MIDDLE NAME'] =	name[1]
			filled_array['PATIENT ALIGNED PHYSICIAN LAST NAME'] =	name[2]

			{
				table_name => filled_array
			}

		elsif table_content[0][:tr][0][:th].first.present? && table_content[0][:tr][1].present? && table_content[0][:tr][1][:th].first.present?
			table_content.reject!{ |a| a[:tr].length != table_content[0][:tr].length }

			hash_comp = map_keys_complex_table(table_content, table_name, head_count)

			if table_name == 'Patient and Plan Detail'
				hash_comp = merge_complex_table(dummy_array_for_complex_table,hash_comp)
			end

			hash_comp
		end
	end


	def parse_0H_table(table_content, table_name, head_count, additional_info, container_info)
		if table_content.length == 1 && table_name.present? && (container_info.present? || additional_info.present?)
			{
				table_name => {"Additional Notes"=> (additional_info.present? ? additional_info : container_info)}
			}
		end
	end


	def dummy_array_for_complex_table
		{
			"Patient Detail"=>{
					"Patient ID"=>"",
					"Group No."=>"",
					"Prefix"=>"",
					"First Name"=>"",
					"Middle Name"=>"",
					"Last Name"=>"",
					"Suffix"=>"",
					"Gender"=>"",
					"DOB"=>"",
					"Address 1"=>"",
					"Address 2"=>"",
					"City"=>"",
					"State"=>"",
					"Zip"=>"",
					"Relationship to Subscriber"=>"",
					"PHONE NO."=>"",
					"FAX NO."=>"",
					"EMAIL"=>""
				},
			"Subscriber Detail"=>{
				"Prefix"=>"",
				"First Name"=>"",
				"Middle Name"=>"",
				"Last Name"=>"",
				"Gender"=>"",
				"DOB"=>"",
				"Address 1"=>"",
				"Address 2"=>"",
				"City"=>"",
				"State"=>"",
				"Zip"=>"",
				"PHONE NO."=>"",
				"FAX NO."=>"",
				"EMAIL"=>""
			},
			"Plan and Network Detail"=>{
				"Plan Type"=>"",
				"Account Name"=>"",
				"Account No."=>"",
				"Initial Coverage Date"=>"",
				"Current Coverage From"=>"",
				"Current Coverage To"=>"",
				"Other Insurance Verified"=>"",
				"ADDITIONAL NOTES"=>""
			},
			"Contacts"=>{
				"Provider Services"=>"",
				"Member Services"=>"",
				"Claims Address 1"=>"",
				"CLAIMS ADDRESS 2"=>"",
				"CLAIMS CITY"=>"",
				"CLAIMS STATE"=>"",
				"CLAIMS ZIP"=>"",
				"ELECTRONIC CLAIMS"=>"",
				"ADDITIONAL NOTES"=>""
			}
		}
	end

def merge_complex_table(dummy_array,hash_comp)

		hash_comp.each do |key,value|
			value.each do |val_key,val|

				if key == "Patient Detail"
					if val_key == "Name"
						p_name = val.split
						dummy_array["Patient Detail"]["First Name"]=p_name[0]
						if p_name.count == 2
							dummy_array["Patient Detail"]["Last Name"]=p_name[1]
						elsif p_name.count==3
							dummy_array["Patient Detail"]["Middle Name"]=p_name[1]
							dummy_array["Patient Detail"]["Last Name"]=p_name[2]
						end
					elsif val_key == "ID#"
						dummy_array["Patient Detail"]["Patient ID"] = val
					elsif val_key == "Gender"
						dummy_array["Patient Detail"]["Gender"] = val
					elsif val_key == "Date of Birth"
						dummy_array["Patient Detail"]["DOB"] = val
					elsif val_key == "Relationship"
						dummy_array["Patient Detail"]["Relationship to Subscriber"] = val
					elsif val_key == "Address"
						dummy_array["Patient Detail"]["Address 1"] = val
						add = val.split(',')
						sz = add[1].split

						ct = add[0].split
						len=ct.count
						dummy_array["Patient Detail"]["City"] = ct[len-2]+" "+ct[len-1]
						dummy_array["Patient Detail"]["State"] = sz[0]
						dummy_array["Patient Detail"]["Zip"] = sz[1]

					end

				elsif key == "Subscriber Detail"

					if val_key == "Name"
						p_name = val.split
						dummy_array["Subscriber Detail"]["First Name"] = p_name[0]
						if p_name.count == 2
							dummy_array["Subscriber Detail"]["Last Name"] =p_name[1]
						elsif p_name.count==3
							dummy_array["Subscriber Detail"]["Middle Name"] = p_name[1]
							dummy_array["Subscriber Detail"]["Last Name"] = p_name[2]
						end

					elsif val_key == "Date of Birth"
						dummy_array["Subscriber Detail"]["DOB"] = val
					end

				elsif key == "Plan and Network Detail"

					if val_key == "Plan Type"
						dummy_array["Plan and Network Detail"]["Plan Type"] = val
					elsif val_key == "Plan Funding Type"

					elsif val_key == "Initial Coverage Date"
						dummy_array["Plan and Network Detail"]["Initial Coverage Date"] = val
					elsif val_key == "Current Coverage From"
						dummy_array["Plan and Network Detail"]["Current Coverage From"] = val
					elsif val_key == "Current Coverage To"
						dummy_array["Plan and Network Detail"]["Current Coverage To"] = val
					elsif val_key == "Other Insurance Verified"
						dummy_array["Plan and Network Detail"]["Other Insurance Verified"] = val
					elsif val_key == "Account #"
						dummy_array["Plan and Network Detail"]["Account No."] = val
					elsif val_key == "Account Name"
						dummy_array["Plan and Network Detail"]["Account Name"] = val
					end

				elsif key == "Contacts"

					if val_key == "Provider Services"
						dummy_array["Contacts"]["Provider Services"] = val
					elsif val_key == "Member Services"
						dummy_array["Contacts"]["Member Services"] = val

					end
				end
			end

		end
		dummy_array
	end


	def dummy_array_for_h1_table(table_content)
		if table_content[0][:tr][0][:th].first.present? && table_content[0][:tr][1].present? && table_content[0][:tr][1][:th].first.to_s.include?('In-Network')
			array =
			{
				"PROGRAM NAME"=>"",
				"FAILURE TO NOTIFY CIGNA- IN NETWORK"=>"",
				"FAILURE TO NOTIFY CIGNA- OUT OF NETWORK"=>"",
				"PRECERTIFICATION NOT APPROVED- IN NETWORK"=>"",
				"PRECERTIFICATION NOT APPROVED- OUT OF NETWORK"=>"",
				"ADDITIONAL DAYS NOT APPROVED - IN NETWORK"=>"",
				"ADDITIONAL DAYS NOT APPROVED - OUT OF NETWORK"=>"",
				"EMERGENCY SERVICE NOTIFICATION - IN NETWORK"=>"",
				"EMERGENCY SERVICE NOTIFICATION - OUT OF NETWORK"=>"",
				"OUTPATIENT PRE CERTIFICATION - IN NETWORK"=>"",
				"OUTPATIENT PRE CERTIFICATION - OUT OF NETWORK"=>"",
				"CONTINUED STAY REVIEW - IN NETWORK"=>"",
				"CONTINUED STAY REVIEW - OUT OF NETWORK"=>"",
				"ADDITIONAL NOTES"=>""
			}

		elsif (table_content[0][:tr][0][:th].first.blank? || table_content[0][:tr][0][:th].first.nil?) && table_content[0][:tr][1].present? && (table_content[0][:tr][1][:th].first.blank? || table_content[0][:tr][1][:th].first.nil?)
			array =
			{
				"CODE"=>"",
				"CARE COORDINATION PROVIDER"=>"",
				"PATIENT ALIGNED PHYSICIAN FIRST NAME"=>"",
				"PATIENT ALIGNED PHYSICIAN MIDDLE NAME"=>"",
				"PATIENT ALIGNED PHYSICIAN LAST NAME"=>"",
				"PATIENT ALIGNED PHYSICIAN NPI"=>"",
				"PATIENT ALIGNED MEDICAL GROUP NAME"=>"",
				"CARE COORDINATION NOTES"=>""
			}
		end


		array
	end
end
