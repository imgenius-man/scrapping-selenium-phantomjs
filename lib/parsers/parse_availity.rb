class ParseAvaility

  def parse_panels(json_obj)
    data_arr = []
        
    data_arr << parse_general_info(json_obj["Coverage"]) if json_obj["Coverage"].present?


    json_obj["Coverage"].each {|key,value|
      puts key
      if key == "patient"
        data_arr << parse_patient_info(json_obj["Coverage"][key])
        
      
      elsif key == "subscriber"
        data_arr << parse_subscriber_info(json_obj["Coverage"][key])
        
      # elsif key == "payer"
      #   data_arr << parse_payer_info(json_obj["Coverage"][key])

      elsif key == "plans"
        data_arr << parse_plan_info(json_obj["Coverage"][key])
        

      elsif key == "requestingProvider"
        data_arr << parse_provider_info(json_obj["Coverage"][key])
        
          
      end
    }

    puts "Mera theek ha"

    coverage_details(json_obj).each do |hash|
      data_arr << hash  
    end    
    puts "Saara theek ha"

    data_arr
  end

  def coverage_details(hash)
    puts "andar tak sai chala"
    
    @json = []
    benefits = hash['Coverage']['plans']['plans']['benefits']['benefits'] if hash['Coverage']['plans'].present? && hash['Coverage']['plans']['plans'].present?  && hash['Coverage']['plans']['plans']['benefits'].present?  && hash['Coverage']['plans']['plans']['benefits']['benefits'].present?
    
    parse = ParseTable.new

    if benefits.present?
      benefits.each do |benefit| 
        @array = {}

        table_array = parse.dummy_array_for_h2_table_availity()
        
        if benefits.is_a?(Array) && benefit['amounts'].present?
          benefit['amounts'].each do |nam_key, name|
            name.each do |n_key, network|
              if network.present? && network[n_key].present? && network[n_key][0].nil?
                data_management(nam_key, n_key, network[n_key])
              end
              
              if network.present? && network[n_key].present? && network[n_key][0].present?
                network[n_key].each do |data|
                  data_management(nam_key, n_key, data)
                end
              end
            end
          end
        
        @array['CODE'] = benefit['type']
        
        table_array.each do |k,v|
          table_array[k] = @array[k.upcase.gsub(/[-\s+]/,'')] if @array[k.upcase.gsub(/[-\s+]/,'')].present?
        end
        
        @json << {benefit['name'] => table_array}
        end
      end
    end
    puts "yahan tak sai chala"
    @json
  end

   def data_management(nam_key, n_key, data)
    level ||= data['level']
    remaining ||= data['remaining']
    
    if nam_key == 'coPayment'
      @array['COPAY(TYPE)INNETWORK'] = data['amount'] if data['level'] == 'Individual' && n_key == 'inNetwork'
      @array['COPAY(TYPE)OUTOFNETWORK'] = data['amount'] if data['level'] == 'Individual' && n_key == 'outOfNetwork'
      
    elsif nam_key == 'coInsurance'
      @array['COINSURANCE(STANDARD)INNETWORK'] = data['amount'] if data['level'] == 'Individual' && n_key == 'inNetwork'
      @array['COINSURANCE(STANDARD)OUTOFNETWORK'] = data['amount'] if data['level'] == 'Individual' && n_key == 'outOfNetwork'
      
    end
    
    if remaining.present?
      @array["#{level.to_s}#{nam_key}amount#{n_key}".upcase.gsub(/[-\s+]/,'').gsub('DEDUCTIBLES','DEDUCTIBLE')] = data['total']
      @array["#{level.to_s}#{nam_key}met#{n_key}".upcase.gsub(/[-\s+]/,'').gsub('DEDUCTIBLES','DEDUCTIBLE')] = data['amount']
      @array["#{level.to_s}#{nam_key}remaining#{n_key}".upcase.gsub(/[-\s+]/,'').gsub('DEDUCTIBLES','DEDUCTIBLE')] = data['remaining']
    end
  end

  def parse_subscriber_info(json_arr)
    subscriber_info = []
    
    subscriber_info << {"First Name"=>json_arr["firstName"]}
    
    subscriber_info << {"Middle Name"=>json_arr["middleName"]}

    subscriber_info << {"Last Name"=>json_arr["lastName"]}
    
    subscriber_info << {"Gender"=>json_arr["gender"]}
    
    subscriber_info << {"DOB"=>json_arr["birthDate"].split("T").first} if json_arr["birthDate"].present?
    
    
    if json_arr["address"].present?

      subscriber_info << {"Address 1"=>json_arr["address"]["line1"]}

      subscriber_info << {"City"=>json_arr["address"]["city"]}
      
      subscriber_info << {"State"=>json_arr["address"]["stateCode"]}
      
      subscriber_info << {"Zip"=>json_arr["address"]["zipCode"]} 
    
    elsif 
      subscriber_info << {"Address 1"=>""}

      subscriber_info << {"City"=>""}
      
      subscriber_info << {"State"=>""}
      
      subscriber_info << {"Zip"=>""} 
    end


    subscriber_info = subscriber_info.reduce({},:merge)

    subscriber_info= {'SUBSCRIBER'=>subscriber_info}

  end

  def parse_plan_info(json_arr)
    plan_info = []
    
    # plan_info << {""=> json_arr["plans"]["groupNumber"]}
    # plan_info << {""=> json_arr["plans"]["groupName"]}
    # json_arr["plans"]["coverageStartDate"]
    # json_arr["plans"]["coverageEndDate"]
    plan_info << {"Plan Type"=>json_arr["plans"]["insuranceType"]} if json_arr["plans"].present?
   # plan_info << {"Plan Type"=>json_arr["plans"]["benefits"]["benefits"][0]["statusDetails"]["noNetwork"]["noNetwork"]["description"]}
    # json_arr["plans"]["insuranceTypeCode"]

    plan_info = plan_info.reduce({},:merge)
    plan_info = {"PLAN DETAILS"=>plan_info}
  end

  def parse_payer_info(json_arr)
   payer_info = []

   payer_info << {""=>json_arr["name"]}
   payer_info << {""=>json_arr[""]}
   payer_info << {""=>json_arr[""]}
   payer_info << {""=>json_arr[""]}

    # 
   payer_info =payer_info.reduce({},:merge)
   payer_info={'PAYeR'=>payer_info}


  end

  def parse_provider_info(json_arr)
    provider_info = []
  
    provider_info << {"PATIENT ALIGNED PHYSICIAN LAST NAME"=>json_arr["lastName"].split("&#").first.strip} if json_arr["lastName"].present?
    
    provider_info << {"PATIENT ALIGNED PHYSICIAN NPI"=>json_arr["npi"]}
    # provider_info << {""=>json_arr["placeOfService"]}
    
    
    if json_arr["address"].present?

      provider_info << {"Address 1"=>json_arr["address"]["line1"]}

      provider_info << {"City"=>json_arr["address"]["city"]}
      
      provider_info << {"State"=>json_arr["address"]["stateCode"]}
      
      provider_info << {"Zip"=>json_arr["address"]["zipCode"]} 
    
    elsif 
      provider_info << {"Address 1"=>""}

      provider_info << {"City"=>""}
      
      provider_info << {"State"=>""}
      
      provider_info << {"Zip"=>""} 
    end
    

    provider_info = provider_info.reduce({},:merge)

    provider_info = {"PLAN PROVIDER"=>provider_info}
  
  end

  def parse_general_info(json_arr)

    status = "Inactive"
    status = json_arr["plans"]["plans"]["status"] if json_arr["plans"].present?
    if status.downcase.include? 'inactive'
      status= "Inactive"
    else
      status = "Active"
    end
    
    t = Time.now
    time = t.strftime("%I:%M%p")

    date = Time.now.to_s

    asOfDate = json_arr["asOfDate"].split('T').first if  json_arr["asOfDate"].present?
    
    general_info = []

    general_info << {"Eligibility Status"=>status}

    general_info << {"Eligibility As Of"=>asOfDate}

    general_info << {"TRANSACTION DATE"=>date}

    general_info << {"TRANSACTION TIME"=>time}

    general_info = general_info.reduce({},:merge)
    general_info = {"GENERAL"=>general_info}

  
  end

  def parse_patient_info(json_arr)
    patient_info = []

    patient_info << {"First Name"=>json_arr["firstName"]}
    
    patient_info << {"Middle Name"=>json_arr["middleName"]}

    patient_info << {"Last Name"=>json_arr["lastName"]}
    
    patient_info << {"Relationship to Subscriber"=>json_arr["subscriberRelationship"]}
    
    patient_info << {"Gender"=>json_arr["gender"]}
    
    patient_info << {"DOB"=>json_arr["birthDate"].split("T").first} if json_arr["birthDate"].present?
    

    if json_arr["address"].present?

      patient_info << {"Address 1"=>json_arr["address"]["line1"]}

      patient_info << {"City"=>json_arr["address"]["city"]}
      
      patient_info << {"State"=>json_arr["address"]["stateCode"]}
      
      patient_info << {"Zip"=>json_arr["address"]["zipCode"]} 
    
    elsif 
      patient_info << {"Address 1"=>""}

      patient_info << {"City"=>""}
      
      patient_info << {"State"=>""}
      
      patient_info << {"Zip"=>""} 
    end

    patient_info = patient_info.reduce({},:merge)

    patient_info = {"PATIENT"=>patient_info}

  end

end