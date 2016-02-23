class User < ActiveRecord::Base
	require 'csv'
	 
  attr_accessible :dob, :first_name, :last_name, :patient_id

	def self.json_table(table_content, table_name, head_count)
    if head_count == 0
      return true
    
    elsif head_count == 1
    	return true
    
    elsif head_count == 2
      if table_content[0][:tr][0][:th].first.present?
      	{ 
      		table_name + " - " +table_content[0][:tr][0][:th].inject(&:+) => 
      			table_content[head_count..table_content.length].map do |tr|
      				tr[:tr][1..tr[:tr].length].map.with_index(1) do |td, i|
      					{ tr[:tr][0][:td].inject(&:+) + " - " +table_content[1][:tr][i][:th].inject(&:+).to_s => td[:td].inject(&:+) }
      				end 
      			end 
      	}
      	
      
      elsif table_content[0][:tr][0][:th].first.nil?
      	return true
      end
    end      
  end
end
