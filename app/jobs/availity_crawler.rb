class AvailityCrawler < Struct.new(:pat_id,:patient_id,:patient_dob,:username,:pass,:site_url,:name_of_organiztion,:payer_name,:provider_name,:place_service_val,:benefit_val)

	def perform
		patient = Patient.find(pat_id)

		@json_arr = []
		@json_arr = Patient.new_availity(patient_id,patient_dob,username,pass,site_url)

    patient.update_attribute('json', JSON.generate(@json_arr))
    patient.update_attribute('record_available', 'complete')

 
  end
end
