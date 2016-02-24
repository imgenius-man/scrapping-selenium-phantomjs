class User < ActiveRecord::Base
	require 'csv'
	 
  attr_accessible :dob, :first_name, :last_name, :patient_id

	
	def self.json_table(table_content, table_name, head_count, container_info)
    if head_count == 0
      parse_0H_table(table_content, table_name, head_count, container_info)
    
    elsif head_count == 1
    	parse_1H_table(table_content, table_name, head_count)
    
    elsif head_count == 2
      parse_2H_table(table_content, table_name, head_count)
    end
  end  

  
  def self.map_keys(table_content, head_count)
  	table_content[head_count..table_content.length].map do |tr|
			tr[:tr][1..tr[:tr].length].map.with_index(1) do |td, i|
				# next if td[:td].inject(&:+).present? && td[:td].inject(&:+) == "--"

				if tr[:tr].length/2 >= i
					network = table_content[0][:tr][1][:th].first.to_s
				
				elsif tr[:tr].length/2 < i
					network = table_content[0][:tr][2][:th].first.to_s
				end

				value = td[:td].inject(&:+).to_s

				if head_count == 2
					key_value_hash_for_2HT(tr, table_content, network, value, i)
				
				elsif head_count == 1
					key_value_hash_for_1HT(tr, network, value)
				end
			end 
		end 
  end


  def self.key_value_hash_for_2HT(tr, table_content, network, value, i)
		{ 
			tr[:tr][0][:td].inject(&:+).to_s + " " + table_content[1][:tr][i][:th].inject(&:+).to_s + " - " + network => value 
		}
  end


  def self.key_value_hash_for_1HT(tr, network, value)
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


  def self.parse_2H_table(table_content, table_name, head_count)
  	if table_content[0][:tr][0][:th].first.present?
    	{ 
    		table_name + " - " +table_content[0][:tr][0][:th].inject(&:+).to_s => 
    			map_keys(table_content, head_count)
    	}
    	
    elsif table_content[0][:tr][0][:th].first.nil?
    	{ 
    		table_name => map_keys(table_content, head_count)
    	}
    end
  end


  def self.parse_1H_table(table_content, table_name, head_count)
  	if table_content[0][:tr][0][:th].first.present? && table_content[0][:tr][1][:th].first.to_s.include?('In-Network')
  		{ 
    		table_name + " - " +table_content[0][:tr][0][:th].inject(&:+).to_s => 
    			map_keys(table_content, head_count)
    	}

    elsif (table_content[0][:tr][0][:th].first.blank? || table_content[0][:tr][0][:th].first.nil?)  && table_content[0][:tr][1][:th].first.to_s.include?('In-Network')	
  		{ 
    		table_name => map_keys(table_content, head_count)
    	}
    
    elsif table_content[0][:tr][0][:th].first.present? && (table_content[0][:tr][1][:th].first.blank? || table_content[0][:tr][1][:th].first.nil?)	
  		{ 
    		table_name => map_keys(table_content, head_count)
    	}
  	
  	elsif table_content[0][:tr][0][:th].first.present? && table_content[0][:tr][1][:th].first.present?  
  		return false	
  	end
  end


  def self.parse_0H_table(table_content, table_name, head_count, container_info)      
  	if table_content.length == 1 && table_name.present? && container_info.present?
  		{
  			table_name => {  "Additional Notes"=> container_info }
  		}
  	end
  end
end
