require 'parsers/parse_eligibility'
class EligibilityApi
	def send(params)
		params = {
			:api_key=>"TneErbrxyRnO1M1q4G8zrvqzArl79mugZSHW", 
			:payer_id=>params['payer_id'], :provider_npi=>params['p_npi'], 
			:provider_first_name=>params['p_first_name'], 
			:provider_last_name=>params['p_last_name'], :member_id=>params['ins_id'], :member_first_name=>params['first_name'], :member_last_name=>params['last_name'], :member_dob=>params['dob'], :service_type=>params['service_type'], :multiple_stc=>true} 
		current_json_string = RestClient.get("https://gds.eligibleapi.com/v1.4/coverage/all.json", params: params)
		current_array = JSON.parse(current_json_string)
		return ParseEligibility.new.get_coverage_json(current_array)
	end
end
# params = {
# 			:api_key=>"TneErbrxyRnO1M1q4G8zrvqzArl79mugZSHW", 
# 			:payer_id=>"ILBLS", :provider_npi=>"1881868669", 
# 			:provider_first_name=>"Andy", 
# 			:provider_last_name=>"Stroud", :member_id=>"XOF823201728", :member_first_name=>"Howard", :member_last_name=>"Goldsmith", :member_dob=>"1989-10-17", :service_type=>"98", :multiple_stc=>true} 
# http://screencast.com/t/yI7Z5NJed
