class User < ActiveRecord::Base
	require 'csv'
	 
  attr_accessible :dob, :first_name, :last_name, :patient_id

	def self.json_table(table_content, table_name, head_count)
    if head_count == 0
      return false
    
    elsif head_count == 1
    	return false
    
    elsif head_count == 2
      if table_content[0][:tr][0][:th].first.present?
      	{ 
      		table_name + " - " +table_content[0][:tr][0][:th].inject(&:+).to_s => 
      			parse_double_header_table(table_content, head_count)
      	}
      	
      elsif table_content[0][:tr][0][:th].first.nil?
      	{ 
      		table_name => parse_double_header_table(table_content, head_count)
      	}
      end
    end
  end  

  def self.parse_double_header_table(table_content, head_count)
  	table_content[head_count..table_content.length].map do |tr|
			tr[:tr][1..tr[:tr].length].map.with_index(1) do |td, i|
				# next if td[:td].inject(&:+).present? && td[:td].inject(&:+) == "--"

				if tr[:tr].length/2 >= i
					network = table_content[0][:tr][1][:th].first.to_s
				
				elsif tr[:tr].length/2 < i
					network = table_content[0][:tr][2][:th].first.to_s
				end

				value = td[:td].inject(&:+).to_s

				{ tr[:tr][0][:td].inject(&:+).to_s + " " + table_content[1][:tr][i][:th].inject(&:+).to_s + " - " + network => value }
			end 
		end 
  end      
end
