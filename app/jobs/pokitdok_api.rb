require 'pokitdok'
require 'parsers/parse_pokitdok'
class PokitdokApi
	def send(params)
		pd = PokitDok::PokitDok.new("dZFVMt1fWkbw0gvEFsNd", "4Qvhj8vpmrkJZsFk4OCr12IGK2Oc2XEKkPS3XgcX")

		@eligibility_query = {
		member: {
		birth_date: params[:dob],
		first_name: params[:first_name],
		last_name: params[:last_name],
		id: params[:ins_id]
		},
		service_types: [params[:service_type]],
		trading_partner_id: params[:payer_id]
		}

		current_array = pd.eligibility @eligibility_query
		return ParsePokitdok.new.coverage_json(current_array)
	end
end

# @eligibility_query = {
# 		member: {
# 		birth_date: '1970-01-01',
# 		first_name: 'Jane',
# 		last_name: 'Doe',
# 		id: 'W000000000'
# 		}