class ParseAvaility

	def parse_panels(driver,panels)
		data_arr = []

		data_arr << Patient.parse_general_info(driver)

		panels.each_with_index do |panel,index|
			heading = panel.find_elements(:class, 'panel-heading')
			if !heading.empty?
				heading = heading.first.text
				if heading.downcase.tr(' ','') == "Subscriber Information".downcase.tr(' ','') || heading.downcase.squish.tr(' ','') == "Patient Information Subscriber Information".downcase.tr(' ','') ||  heading.downcase.tr(' ','') == "Patient Information".downcase.tr(' ','')
					puts "Going in Subscriber Deatil"
					data_arr <<  parse_subscriber_info(panel,driver)
					puts 'Subscriber Deatil'
				elsif heading.downcase.tr(' ','').tr('/','') == "Plan / Product Information".downcase.tr(' ','').tr('/','')
					puts "Going in Plan Detail"
					data_arr <<  parse_plan_info(panel,driver)
					puts "Plan Detail"
				elsif heading.downcase.squish.tr(' ','') == "Payer Details\nOther or Additional Payers".downcase.squish.tr(' ','')
					puts "Going in Payer Deatil"
					data_arr <<  parse_payer_info(panel,driver)
					puts 'Payer Deatil'
				elsif heading.downcase.tr(' ','') == "Provider Details".downcase.tr(' ','')
					puts "Going in Provider Deatil"
					data_arr <<  parse_provider_info(panel,driver)
					puts 'Provider Deatil'
				elsif index == 0
					puts "Going in Patient Deatil"
					data_arr << parse_patient_info(panel,driver)
					puts 'Patient Detail'
				end
			end
		end

		a =driver.find_elements(:css, '#tab > li:nth-child(2) > a:nth-child(1)').first.click
		sleep(2)

		a =driver.find_elements(:css, 'ul.nav-pills:nth-child(1)> li ')
		a.last.click

		data_arr << coverage_details(driver)

	end

	def coverage_details(driver)
		parse = ParseTable.new

    @json = []

    driver.find_elements(:css, '.service-types-container > .unstyled > li').each do |html|

      li_html = html.attribute('innerHTML')

      li_html

      table_array = parse.dummy_array_for_h2_table_availity()

      page = Mechanize::Page.new(nil,{'content-type'=>'text/html'},li_html,nil,Mechanize.new)

      header = page.at('h3').text.squish

      key = []

      page.search('.panel.panel-condensed').each do |sub_container|
        string = sub_container.at('h4').text.squish
        if string.scan('-').count == 1
          key[1] = string.split(/[-(]/).first # check this - there are more "-" in co=payment and co-insurence

        elsif string.scan('-').count > 1
          arr = string.split('-')
          arr[arr.length-1] = ''

          string = arr.inject(:+)

          key[1] = string.split('(').first # check this - there are more "-" in co=payment and co-insurence
        end

        data = sub_container.at('div').text.squish.split('Remaining')
        data_sv = sub_container.at('div').text.squish.split(/(In\s+|Out\s+)/).reject{|v| v == 'Out ' || v == 'In ' || v == ''}

        arr = []
        if data[0].scan('$').count == 3
          data.each do |row|
            row.strip!

            if row.scan('In Network').present?
              key[2] = 'In Network'

            elsif row.scan('Out Of Network').present?
              key[2] = 'Out Of Network'
            end

            if row.scan('Family').present?
              key[0] = 'Family'

            elsif row.scan('Individual').present?
              key[0] = 'Individual'
            end

            costs = row.split.reject{|a| a if !a.scan('$').present?}

            final_key_amount = key[0].to_s+key[1].to_s+'AMOUNT'+key[2].to_s
            arr << {final_key_amount.upcase.gsub(/[-\s+]/,'') => costs[0]}

            final_key_met = key[0].to_s+key[1].to_s+'MET'+key[2].to_s
            arr << {final_key_met.upcase.gsub(/[-\s+]/,'') => costs[1]}

            final_key_remaining = key[0].to_s+key[1].to_s+'Remaining'+key[2].to_s
            arr << {final_key_remaining.upcase.gsub(/[-\s+]/,'') => costs[2]}

          end

          arr = arr.reduce({},:merge)

          da = table_array.each do |k,v|
            table_array[k] = arr[k.upcase.gsub(/[-\s+]/,'')] if arr[k.upcase.gsub(/[-\s+]/,'')].present?
          end
        end

        if data_sv[0].scan(/[$%]/).count == 1
          data_sv.each do |row|
            puts row

            row.strip!

          	if row.scan('Of Network').present?
              key[2] = 'Out Of Network'

            elsif row.scan('Network').present?
              key[2] = 'In Network'
            end

						if row.scan('Family').present?
              key[0] = 'Family'

            elsif row.scan('Individual').present?
              key[0] = 'Individual'
						end

            row = row.split

            costs = row.map.with_index(0) do |a, i|
              if a.scan('$').present?
                v = a
              elsif a.scan('%').present?
                v = row[i-1]+'%'
              end

              v
            end

            if key[1].upcase.gsub(/[-\s+]/,'') == 'COPAYMENT' && key[2].present?
              puts "==="*100
              puts "COPAY (TYPE)- #{key[2].to_s.upcase}"
              table_array["COPAY (TYPE)- #{key[2].to_s.upcase}"] = costs.reject(&:nil?).inject(:+)

            elsif key[1].upcase.gsub(/[-\s+]/,'') == 'COINSURANCE' && key[2].present?
              puts "==="*100
              puts "COINSURANCE (STANDARD)- #{key[2].to_s.upcase}"
              table_array["COINSURANCE (STANDARD)- #{key[2].to_s.upcase}"] = costs.reject(&:nil?).inject(:+)
            end
          end
        end
        puts table_array.inspect
      end

      table_array['CODE'] = header.split('-').last

      @json << { header.split('-').first.to_s => table_array }

    end
    puts @json.inspect

	end

	def parse_subscriber_info(panel,driver)
		subscriber_info = []
		if panel.find_element(:class, 'patientAddress')
			address = panel.find_element(:class, 'patientAddress').text.split("\n")
			address_1 = address.first
			cit_st_zip = address.last.split(',')
			city = cit_st_zip.first
			state = cit_st_zip.last.strip.split(' ').first
			zip_code = cit_st_zip.last.strip.split(' ').last

			subscriber_info << {'ADDRESS 1'=>address_1,'City'=> city,'State'=> state,'Zip'=> zip_code}

		end

		sub_info = panel.find_elements(:css, '.panel-body > div.span6 > ul > li')

		if sub_info!=nil


			keys = ["PLAN NAME","PLAN NUMBER","RELATIONSHIP TO SUBSCRIBER","MEMBER ID","GROUP NUMBER","PLAN SPONSOR NAME","SUBSCRIBER"]
			li =sub_info

			li.each {|l|
				keys.each_with_index{|key,index|
					if l.text.include? key
						if key != "SUBSCRIBER"
							subscriber_info << {key => l.text.split(key).last.strip}
						elsif

							subscriber_name =  l.text.split(key).last.strip

							full_name = subscriber_name.split(',')
							last_name = full_name.first

							rest_name = full_name.last.split(' ')

							first_name = rest_name.first
							middle_name = rest_name.last if rest_name.count > 1
							subscriber_info << {"First Name" => first_name}
							subscriber_info << {"Last Name" => last_name}
							subscriber_info << {"Middle Name" => middle_name}

						end
					end
				}
			}

		end

		 subscriber_info = subscriber_info.reduce({},:merge)

		subscriber_info= {'SUBSCRIBER'=>subscriber_info}

	end

	def parse_plan_info(panel,driver)
		plan_info = []
		li = panel.find_elements(:tag_name, 'li')

		keys = ["INSURANCE TYPE", "PLAN / PRODUCT"]

		li.each {|l|
			keys.each{|key|
				if l.text.include? key
					plan_info << {key => l.text.split(key).last.strip}
				end
			}
		}

		plan_info = {"Plan Details"=>plan_info}
	end

	def parse_payer_info(panel,driver)

		payer_details = panel.find_elements(:class, 'span6')[2] if  panel.find_elements(:class, 'span6').count == 4
		ul = payer_details.find_elements(:tag_name,'ul')
		keys  = ["NAME","TYPE"]
		val_arr=[]
		payer_info = []

		 if ul.count>1
			 li = ul[1].find_elements(:tag_name,'li')
			 li.each {|l|
				 keys.each{|key|
					 if l.text.include? key
						 payer_info << {key => l.text.split(key).last.strip}
					 end
				 }
			 }
		 end

		 contact_info = panel.find_elements(:class, 'contact-information')
		 if !contact_info.empty?
			 payer_contact_name = contact_info.first.text.split("\n").first.strip
			 payer_contact_number = contact_info.first.text.split(':').last.strip
			#  payer_info << {'naem'=>payer_contact_name}
			#  payer_info << {'numb'=>payer_contact_number}
		 end


		 payer_info =payer_info.reduce({},:merge)
		 payer_info={'PAYeR'=>payer_info}


	end

	def parse_provider_info(panel,driver)
		provider_info = []
		p_detail = panel.find_elements(:class,'span6').last
		p_address = p_detail.find_elements(:tag_name, 'div').first
		if p_address != nil
			provider_address = p_address.text.split("\n")
			address_1 = provider_address[0]+" "+provider_address[1]

			cit_st_zip = provider_address[2].split(',')
			city = cit_st_zip[0]
			state = cit_st_zip[1].strip.split(' ').first
			zip_code = cit_st_zip[1].strip.split(' ').last

			provider_info << {'ADDRESS 1'=>address_1,'City'=> city,'State'=> state,'Zip'=> zip_code}

		end

		li = p_detail.find_elements(:tag_name, 'li')
		keys = ["NAME", "TYPE", "ROLE", "NPI" , "PLACE OF SERVICE"]

		li.each {|l|
			keys.each{|key|
				if l.text.include? key
					provider_info << {key => l.text.split(key).last.strip}
				end
			}
		}




		provider_info = provider_info.reduce({},:merge)

		provider_info = {"PLAN PROVIDER"=>provider_info}

	end

	def parse_general_info(driver)

	 transaction_details = driver.find_element(:css, '.inline')

	 li = transaction_details.find_elements(:tag_name, 'li')

	 trans_datetime = li[1].text.split('Date:').last.strip.split(' ')

	 transaction_date = trans_datetime[0]+' '+ trans_datetime[1]
	 transaction_time =  trans_datetime[2]+' '+ trans_datetime[3]

	 status_text = driver.find_element(:css,'div.panel-footer:nth-child(3)').text

	 status = nil
	 if status_text.include? 'Patient is Inactive'
		 status = 'Inactive'
	 else
		 status = 'Active'
	 end
	 general_info = {'Eligibility Status'=>status ,'TRANSACTION DATE'=>transaction_date ,'TRANSACTION TIME'=>transaction_time	}
	 general_info = {'GENERAL'=>general_info}

	end

	def parse_patient_info(panel,driver)
		patient_info = []
		panel_heading = panel.find_elements(:class => 'panel-heading')

		patient_name_relation = panel_heading[0].find_element(:tag_name=> 'h4')
		relation = patient_name_relation.find_element(:tag_name, 'small').text

		patient_name = patient_name_relation.text.split(relation).first.strip

		full_name = patient_name.split(',')
		last_name = full_name.first
		rest_name = full_name.last.split(' ')

		first_name = rest_name.first
		middle_name = rest_name.last if rest_name.count > 1

		li = panel_heading[0].find_elements(:class=> 'span4').first.find_elements(:tag_name, 'li')


		keys=["MEMBER ID","DOB","GENDER"]
		val_arr=[]
		li.each {|l|
			keys.each_with_index{|key,index|
				if l.text.include? key
					patient_info << {key => l.text.split(key).last.strip}
				end
			}
		}
		li = panel_heading[0].find_elements(:class=> 'span8').first.find_elements(:tag_name, 'li')
		keys=["PLAN / COVERAGE DATE","DATE OF SERVICE","ELIGIBILITY END DATE"]

		li.each {|l|
			keys.each_with_index{|key,index|
				if l.text.include? key
					patient_info << {key => l.text.split(key).last.strip}
				end
			}
		}
		patient_info = patient_info.reduce({},:merge)

		patient_info = { 'PATIENT'=>patient_info}
	end


end
