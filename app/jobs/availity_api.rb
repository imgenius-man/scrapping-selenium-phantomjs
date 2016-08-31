
class AvailityApi
  require 'net/http'
  
  def send(params)
    begin     
      
      patient_info = {
        :payerId => 'BCBSIL',
        :providerNpi => '1447277447',
        :memberId => 'MUPXZ3775081',
        :patientLastName => 'NORTHWEST MEDICAL CARE',
        :patientFirstName => 'JAYANTIBHAI',
        :serviceType => '30',
        :patientBirthDate => '1950-08-25'
      }

      url = URI("https://api.availity.com/demo/v1/coverages?"+patient_info.to_query)

      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true

      request = Net::HTTP::Get.new(url)
      request["x-api-key"] = '5g7erw78b855jkx8rmrteh9a'

      response = http.request(request)
      ret = JSON.parse(response.read_body)

      sleep(1)
      
      if ret.present?
        cov_url = ret["coverages"].first['links']['self']['href'] if ret["coverages"].present? && ret["coverages"].first.present? && ret["coverages"].first['links'].present?
        
        if cov_url.present?
          url = URI(cov_url)

          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = true

          request = Net::HTTP::Get.new(url)
          request["x-api-key"] = '5g7erw78b855jkx8rmrteh9a'

          response = http.request(request)
          puts JSON.parse(response.read_body)

        else
          puts ret
        end 

      else
        puts ["no data present"]
      end

    rescue Exception=> e
      return [e.inspect]

    end
 
  end
end

# customer_id = 388016
    # username = 'statpay'
    #pass = 'Swervepay0!'
 # site_url = 'https://apps.availity.com/'

 #patient_dob = '08/25/1950'

 # payerId = 'BCBSIL'
 #provider_lastname = 'NORTHWEST+MEDICAL+CARE'
 #providerNpi = '1447277447'
 #service_type = '30'
 #patient_id = 'MUPXZ3775081'

#  curl -X "POST" "https://api.availity.com/v1/token"  -H "Authorization: Basic eHVzZzd6emh4OGF0OXNiNW5zaHg0eTh6OnNoVEY2eFhyTXJqdVRnRUFZckZI"  -d "grant_type=client_credentials"
# echo -n 'xusg7zzhx8at9sb5nshx4y8z':'shTF6xXrMrjuTgEAYrFH' | base64

# curl -X GET "https://api.availity.com/demo/v1/coverages/123" -H "x-api-key: 5g7erw78b855jkx8rmrteh9a"




# curl -X "GET" "https://api.availity.com/demo/v1/coverages?payerId=BCBSIL&providerNpi=1447277447&memberId=MUPXZ3775081&patientLastName=NORTHWEST+MEDICAL+CARE&patientFirstName=JAYANTIBHAI&serviceType=30&patientBirthDate=1950-08-25" -H "x-api-key: 5g7erw78b855jkx8rmrteh9a"



