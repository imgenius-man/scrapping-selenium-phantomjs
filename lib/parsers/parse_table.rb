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
		
		(row_length).times do |cell_i| 
			if table_name == 'Patient and Plan Detail' 
				arr = traverse_table_columnwise(table_content, row_length, cell_i).reject{|b| b.is_a?(String) || b.blank?} 
				header_arrays << { table_content.first[:tr][cell_i][:th].first => ( arr.is_a?(String) ? arr : arr.reduce({}, :merge) ) } 

			elsif table_name == 'Maternity'
				header_arrays << { table_content.first[:tr][cell_i][:th].first => traverse_table_columnwise(table_content, row_length, cell_i) } 
			
			else
				header_arrays << { table_content.first[:tr][cell_i][:th].first => traverse_table_columnwise(table_content, row_length, cell_i) } 
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
			
			{ 
				table_name + " - " +table_content[0][:tr][0][:th].inject(&:+).to_s => merge_arrays(dummy_array, data_array)
			}
			
		elsif table_content[0][:tr][0][:th].first.nil?
			dummy_array = dummy_array_for_h2_table()
		
			data_array = map_keys(table_content, head_count, additional_info).flatten!.reduce({}, :merge)

			{ 
				table_name => merge_arrays(dummy_array, data_array)
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
			
			filled_array['CARE COORDINATION PROVIDER'] = data_array['CAC Name']
			filled_array['PATIENT ALIGNED PHYSICIAN FIRST NAME'] = name[0]
			filled_array['PATIENT ALIGNED PHYSICIAN MIDDLE NAME'] =	name[1]
			filled_array['PATIENT ALIGNED PHYSICIAN LAST NAME'] =	name[2]

			{
				table_name => filled_array
			}

		elsif table_content[0][:tr][0][:th].first.present? && table_content[0][:tr][1].present? && table_content[0][:tr][1][:th].first.present?  
			table_content.reject!{ |a| a[:tr].length != table_content[0][:tr].length } 
			
			map_keys_complex_table(table_content, table_name, head_count)	
		end
	end


	def parse_0H_table(table_content, table_name, head_count, additional_info, container_info)      
		if table_content.length == 1 && table_name.present? && (container_info.present? || additional_info.present?)
			{
				table_name => {"Additional Notes"=> (additional_info.present? ? additional_info : container_info)}
			}
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
			
			elsif k.upcase.gsub(/[-\s+*]/,'') == "MAXIMUM$(PERCALENDARYEAR)AMOUNTINNETWORK"
				temp["INDIVIDUALDEDUCTIBLEAMOUNTINNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "MAXIMUM$(PERCALENDARYEAR)AMOUNTOUTOFNETWORK"
				temp["INDIVIDUALDEDUCTIBLEAMOUNTINNETWORK"] = v
			
			elsif k.upcase.gsub(/[-\s+*]/,'') == "COPAYMENT(PERVISIT)AMOUNTINNETWORK"
				temp["COPAY(PERVISIT)INNETWORK"] = v

			elsif k.upcase.gsub(/[-\s+*]/,'') == "COPAYMENT(PERVISIT)AMOUNTOUTOFNETWORK"
				temp["COPAY(PERVISIT)OUTOFNETWORK"] = v
			end

			temp[k.upcase.gsub(/[-\s+*]/,'')] = v 
		}

		dummy_array.each{ |k,v| dummy_array[k] = temp[k.upcase.gsub(/[-\s+]/,'')]}
		

		dummy_array
	end


	def dummy_array_for_h2_table
		{
			"EFFECTIVE DATE - IN NETWORK"=>"",
			"EFFECTIVE DATE - OUT OF NETWORK"=>"",
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
			"MAXIMUM VISITS (PER CALENDAR YEAR) AMOUNT- IN NETWORK "=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) MET- IN NETWORK "=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) REMAINING - IN NETWORK"=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) AMOUNT- OUT OF NETWORK "=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) MET- OUT OF NETWORK "=>"",
			"MAXIMUM VISITS (PER CALENDAR YEAR) REMAINING - OUT OF NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) AMOUNT- IN NETWORK "=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) MET- IN NETWORK "=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) REMAINING - IN NETWORK"=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) AMOUNT- OUT OF NETWORK "=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) MET- OUT OF NETWORK "=>"",
			"MAXIMUM DAYS (PER POLICY YEAR) REMAINING - OUT OF NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE AMOUNT- IN NETWORK "=>"",
			"INDIVIDUAL DEDUCTIBLE MET- IN NETWORK "=>"",
			"INDIVIDUAL DEDUCTIBLE REMAINING - IN NETWORK"=>"",
			"FAMILY DEDUCTIBLE AMOUNT- IN NETWORK "=>"",
			"FAMILY DEDUCTIBLE MET- IN NETWORK "=>"",
			"FAMILY DEDUCTIBLE REMAINING - IN NETWORK"=>"",
			"INDIVIDUAL DEDUCTIBLE AMOUNT- OUT OF NETWORK "=>"",
			"INDIVIDUAL DEDUCTIBLE MET- OUT OF NETWORK "=>"",
			"INDIVIDUAL DEDUCTIBLE REMAINING - OUT OF NETWORK"=>"",
			"FAMILY DEDUCTIBLE AMOUNT- OUT OF NETWORK "=>"",
			"FAMILY DEDUCTIBLE MET- OUT OF NETWORK "=>"",
			"FAMILY DEDUCTIBLE REMAINING - OUT OF NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM AMOUNT- IN NETWORK "=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM MET- IN NETWORK "=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM REMAINING - IN NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM AMOUNT- IN NETWORK "=>"",
			"FAMILY OUT OF POCKET MAXIMUM MET- IN NETWORK "=>"",
			"FAMILY OUT OF POCKET MAXIMUM REMAINING - IN NETWORK"=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM AMOUNT- OUT OF NETWORK "=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM MET- OUT OF NETWORK "=>"",
			"INDIVIDUAL OUT OF POCKET MAXIMUM REMAINING - OUT OF NETWORK"=>"",
			"FAMILY OUT OF POCKET MAXIMUM AMOUNT- OUT OF NETWORK "=>"",
			"FAMILY OUT OF POCKET MAXIMUM MET- OUT OF NETWORK "=>"",
			"FAMILY OUT OF POCKET MAXIMUM REMAINING - OUT OF NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM AMOUNT- IN NETWORK "=>"",
			"INDIVIDUAL LIFETIME MAXIMUM MET- IN NETWORK "=>"",
			"INDIVIDUAL LIFETIME MAXIMUM REMAINING - IN NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM AMOUNT- IN NETWORK "=>"",
			"FAMILY LIFETIME MAXIMUM MET- IN NETWORK "=>"",
			"FAMILY LIFETIME MAXIMUM REMAINING - IN NETWORK"=>"",
			"INDIVIDUAL LIFETIME MAXIMUM AMOUNT- OUT OF NETWORK "=>"",
			"INDIVIDUAL LIFETIME MAXIMUM MET- OUT OF NETWORK "=>"",
			"INDIVIDUAL LIFETIME MAXIMUM REMAINING - OUT OF NETWORK"=>"",
			"FAMILY LIFETIME MAXIMUM AMOUNT- OUT OF NETWORK "=>"",
			"FAMILY LIFETIME MAXIMUM MET- OUT OF NETWORK "=>"",
			"FAMILY LIFETIME MAXIMUM REMAINING - OUT OF NETWORK"=>"",
			"ADDITIONAL NOTES"=>""
		}
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

