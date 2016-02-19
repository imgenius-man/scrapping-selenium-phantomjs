class User < ActiveRecord::Base
	require 'csv'
	 
  attr_accessible :dob, :first_name, :last_name, :patient_id

def self.to_csv(options = {},data)
    CSV.generate(options) do |csv|
      tmpa = []
      th = []
      td = []
      data.each do |edata|
        edata.each do |stuff|
          stuff[:tr].each do |row|

              row.map{ |r|
                th.push r[:th] if r[:th]
                td.push r[:td] if r[:td]
              }

          end

        end



      csv << th

      td.each_with_index do |t,index|
        if index%th.length == 0 && index != 0
          csv << tmpa
          tmpa = []
        end
        tmpa.push t
      end
      csv << []
      th = []
      td = []
        end
      end

end
end
