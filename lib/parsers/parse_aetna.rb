class ParseAetna
  require 'parsers/parse_table'
  
  def parse_tables_aetna(tables, copay_ind, coin_ind, oop_ind, deduc_ind)
    puts  "sdfsd"*123
    mega_arr = []
    
    coinsuarance = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[coin_ind].attribute('innerHTML'),nil,Mechanize.new)
    tr = coinsuarance.search('tr')

    tables.each_with_index{|table,index|
     table_name = table.text.squish
     if table_name == "Out of Pocket (Stop Loss)" || table_name == "Deductible" || table_name == "Co insurance" || table_name == "Co payment"
       tr = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[index+2].attribute('innerHTML'),nil,Mechanize.new).search('tr')
        puts "2332323223"
        puts "#{index}: #{table_name}"
        ret = aetna_parse_details(tr,table_name)
        puts ret[0]
        # mega_arr << { ret[1] => ret[0]}
        mega_arr << { ret[1] => map_keys_aetna(ret[0],ParseTable.new.dummy_array_for_tables_aetna)}
     end
    }


 

    # coinsuarance = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[11].attribute('innerHTML'),nil,Mechanize.new)
    # tr = coinsuarance.search('tr')

    # ret = aetna_parse_coinsuarnce(tr)
    # mega_arr << { ret[1] => map_keys_aetna(ret[0],ParseTable.new.dummy_array_for_tables_aetna)}

    copayment = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[copay_ind].attribute('innerHTML'),nil,Mechanize.new)
    tr = copayment.search('tr')

    # ret = aetna_parse_copayment(tr)
    # mega_arr << { ret[1] => map_keys_aetna(ret[0],ParseTable.new.dummy_array_for_tables_aetna)}

    deductibles = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[deduc_ind].attribute('innerHTML'),nil,Mechanize.new)
    tr = deductibles.search('tr')

    # ret = aetna_parse_deductibles(tr)
    # mega_arr << { ret[1] => map_keys_aetna(ret[0],ParseTable.new.dummy_array_for_tables_aetna)}

    out_of_pocket = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[oop_ind].attribute('innerHTML'),nil,Mechanize.new)
    tr = out_of_pocket.search('tr')

    # ret = aetna_parse_out_of_pocket(tr)
    # mega_arr << { ret[1] => map_keys_aetna(ret[0],ParseTable.new.dummy_array_for_tables_aetna)}

    # map_keys_aetna(mega_arr.reduce({},:merge),ParseTable.new.dummy_array_for_tables_aetna)
    mega_arr
  end

  def map_keys_aetna(curr,dummy)
    puts "curr--"*123
    puts curr
    curr.each{ |key,val|

      if key.include? 'Co insurance'
        
        if key.include?('In Network') && key.include?('Amount Limit')
          dummy["COINSURANCE (STANDARD)- IN NETWORK"] = curr[key]
          puts "23"*23
          puts curr[key]
        
        elsif key.include?('Out Network') && key.include?('Amount Limit')
          dummy["COINSURANCE (STANDARD)- OUT OF NETWORK"] = curr[key]
          puts curr[key]
          puts "90"*23
        
        elsif key.include? 'Code'
          puts "43"*23
          dummy["CODE"] = curr[key]
          
        end

      elsif key.include?('Co payment') 
        if key.include?('Amount Limit')
          dummy["COPAY (PER VISIT)- IN NETWORK"] = curr[key]

        elsif key.include?('Code')
          dummy["CODE"] = curr[key]
        end

      elsif key.include? 'Deductible'
        
        if key.include? 'Family'

          if key.include?('In Network') &&  key.include?("Amount Remaining")
            dummy["FAMILY DEDUCTIBLE REMAINING - IN NETWORK"] = curr[key]
          
          elsif key.include?('In Network') &&  key.include?("Amount Limit")
            dummy["FAMILY DEDUCTIBLE AMOUNT- IN NETWORK"] = curr[key]
          
          elsif key.include?('Out Network') && key.include?("Amount Remaining")
            dummy["FAMILY DEDUCTIBLE REMAINING - OUT OF NETWORK"] = curr[key]
          
          elsif key.include?('Out Network') && key.include?("Amount Limit")
            dummy["FAMILY DEDUCTIBLE AMOUNT- OUT OF NETWORK"] = curr[key]

          end
          
        elsif key.include? 'Individual'
          
          if key.include?('In Network') &&  key.include?("Amount Remaining")
            dummy["INDIVIDUAL DEDUCTIBLE REMAINING - IN NETWORK"] = curr[key]
          
          elsif key.include?('In Network') &&  key.include?("Amount Limit")
            dummy["INDIVIDUAL DEDUCTIBLE AMOUNT- IN NETWORK"] = curr[key]
          
          elsif key.include?('Out Network') && key.include?("Amount Remaining")
            dummy["INDIVIDUAL DEDUCTIBLE REMAINING - OUT OF NETWORK"] = curr[key]
          
          elsif key.include?('Out Network') && key.include?("Amount Limit")
            dummy["INDIVIDUAL DEDUCTIBLE AMOUNT- OUT OF NETWORK"] = curr[key]
            
          end

        elsif key.include?('Code')
          dummy["CODE"] = curr[key]
  
        end

      elsif key.include? 'Out of Pocket'

        if key.include? 'Family'

          if key.include?('In Network') &&  key.include?("Amount Remaining")
            dummy["FAMILY OUT OF POCKET MAXIMUM REMAINING - IN NETWORK"] = curr[key]

          elsif key.include?('In Network') &&  key.include?("Amount Limit")
            dummy["FAMILY OUT OF POCKET MAXIMUM AMOUNT- IN NETWORK"] = curr[key]
            
          elsif key.include?('Out Network') && key.include?("Amount Remaining")
            dummy["FAMILY OUT OF POCKET MAXIMUM REMAINING - OUT OF NETWORK"] = curr[key]

          elsif key.include?('Out Network') && key.include?("Amount Limit" )
            dummy["FAMILY OUT OF POCKET MAXIMUM AMOUNT- OUT OF NETWORK"] = curr[key]

          end
          
        elsif key.include? 'Individual'
        
          if key.include?('In Network') &&  key.include?("Amount Remaining")
            dummy["INDIVIDUAL OUT OF POCKET MAXIMUM REMAINING - IN NETWORK"] = curr[key]

          elsif key.include?('In Network') &&  key.include?("Amount Limit")
            dummy["INDIVIDUAL OUT OF POCKET MAXIMUM AMOUNT- IN NETWORK"] = curr[key]
            
          elsif key.include?('Out Network') && key.include?("Amount Remaining")
            dummy["INDIVIDUAL OUT OF POCKET MAXIMUM REMAINING - OUT OF NETWORK"] = curr[key]

          elsif key.include?('Out Network') && key.include?("Amount Limit" )
            dummy["INDIVIDUAL OUT OF POCKET MAXIMUM AMOUNT- OUT OF NETWORK"] = curr[key]

          end

        elsif key.include?('Code')
          dummy["CODE"] = curr[key]
        
        end
      end
    }

    dummy
  end

  def aetna_parse_coinsuarnce(tr)
    th = tr[0].search('th')
    pre = ["In Network","Out Network"]
    js = []
    

    (0..(tr.count/3)-1).each_with_index {|n,ind|

      network_td = []
      network_td = tr[(n*3)+2].search('td')
      network_td.each_with_index {|td,index|
         # puts "Coinsuarnce - #{pre[ind]} - #{th[index].text.squish} => #{td.text.squish}"
        js << {"Coinsuarnce - #{pre[ind]} - #{th[index].text.squish}" => td.text.squish} if td.present? && th[index].present?
      }
    }
    info = tr[1].text.squish if tr[1].present?
    t_name = info.split('-').last.squish if info.present?
    t_code = info.split('-').first.squish if info.present?
    js << {"Coinsuarnce - Code" => t_code}
    
    [js.reduce({},:merge),t_name]
  end

  def aetna_parse_copayment(tr)
    th = tr[0].search('th')
    js = []
    (0..(tr.count/3)-1).each_with_index {|n,ind|
      network_td = []
      network_td = tr[(n*3)+2].search('td')
      network_td.each_with_index {|td,index|
         # puts "Copayment - #{th[index].text.squish} => #{td.text.squish}"
        js << {"Copayment - #{th[index].text.squish}" => td.text.squish} if td.present? && th[index].present?
      }
    }
    info = tr[1].text.squish if tr[1].present?
    t_name = info.split('-').last.squish if info.present?
    t_code = info.split('-').first.squish if info.present?
    js << {"Copayment - Code" => t_code}
    
    [js.reduce({},:merge),t_name]
  end

  def aetna_parse_deductibles(tr)
    th = tr[0].search('th')
    in_out = ["In Network","In Network","Out Network","Out Network"]
    fam_ind = ["Family","Individual","Family","Individual"]
    js = []
    (0..(tr.count/3)-1).each_with_index {|n,ind|
      network_td = []
      network_td = tr[(n*3)+2].search('td')
      network_td.each_with_index {|td,index|
         # puts "Deductibles - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish} => #{td.text.squish}"
        js << {"Deductibles - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish}" => td.text.squish} if td.present? && th[index].present?
      }
    }
    info = tr[1].text.squish if tr[1].present?
    t_name = info.split('-').last.squish if info.present?
    t_code = info.split('-').first.squish if info.present?
    js << {"Coinsuarnce - Code" => t_code}
    [js.reduce({},:merge),t_name]
  end

  def aetna_parse_out_of_pocket(tr)
    th = tr[0].search('th')
    in_out = ["In Network","In Network","Out Network","Out Network"]
    fam_ind = ["Individual","Family","Individual","Family"]
    js = []
    (0..(tr.count/3)-1).each_with_index {|n,ind|
      network_td = []
      network_td = tr[(n*3)+2].search('td')
      network_td.each_with_index {|td,index|
         # puts "Out of Pocket - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish} => #{td.text.squish}"
        js << {"Out of Pocket - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish}" => td.text.squish} if td.present? && th[index].present?
      }
    }
    info = tr[1].text.squish if tr[1].present?
    t_name = info.split('-').last.squish if info.present?
    t_code = info.split('-').first.squish if info.present?
    js << {"Coinsuarnce - Code" => t_code}
    [js.reduce({},:merge),t_name]
  end
  # def aetna_parse_deductibles(tr)
  #   th = tr[0].search('th')
  #   in_out = ["In Network","In Network","Out Network","Out Network"]
  #   fam_ind = ["Family","Individual","Family","Individual"]
  #   js = []
  #   (0..(tr.count/3)-1).each_with_index {|n,ind|
  #     network_td = []
  #     network_td = tr[(n*3)+2].search('td')
  #     network_td.each_with_index {|td,index|
  #        # puts "Deductibles - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish} => #{td.text.squish}"
  #       js << {"Deductibles - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish}" => td.text.squish} if td.present? && th[index].present?
  #     }
  #   }
  #   info = tr[1].text.squish if tr[1].present?
  #   t_name = info.split('-').last.squish if info.present?
  #   t_code = info.split('-').first.squish if info.present?
  #   js << {"Coinsuarnce - Code" => t_code}
  #   [js.reduce({},:merge),t_name]
  # end

  # def aetna_parse_out_of_pocket(tr)
  #   th = tr[0].search('th')
  #   in_out = ["In Network","In Network","Out Network","Out Network"]
  #   fam_ind = ["Individual","Family","Individual","Family"]
  #   js = []
  #   (0..(tr.count/3)-1).each_with_index {|n,ind|
  #     network_td = []
  #     network_td = tr[(n*3)+2].search('td')
  #     network_td.each_with_index {|td,index|
  #        # puts "Out of Pocket - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish} => #{td.text.squish}"
  #       js << {"Out of Pocket - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish}" => td.text.squish} if td.present? && th[index].present?
  #     }
  #   }
  #   info = tr[1].text.squish if tr[1].present?
  #   t_name = info.split('-').last.squish if info.present?
  #   t_code = info.split('-').first.squish if info.present?
  #   js << {"Coinsuarnce - Code" => t_code}
  #   [js.reduce({},:merge),t_name]
  # end

  
  def aetna_parse_details(tr,table_name)
      th = tr[0].search('th')
      js = []
      (0..(tr.count/3)-1).each_with_index {|n,ind|
        network_td = []
        network_td = tr[(n*3)+2].search('td')
        network_td.each_with_index {|td,index|
           # puts "Deductibles - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish} => #{td.text.squish}"
          js << {"#{table_name} - #{network_td[1].text.squish} - In Network - #{th[index].text.squish}" => td.text.squish} if td.present? && th[index].present? && network_td[1].present? && network_td[2].text.squish.downcase == "yes"
          js << {"#{table_name} - #{network_td[1].text.squish} - Out Network - #{th[index].text.squish}" => td.text.squish} if td.present? && th[index].present? && network_td[1].present? && network_td[2].text.squish.downcase == "no"
        }
      }
      info = tr[1].text.squish if tr[1].present?
      t_name = info.split('-').last.squish if info.present?
      t_code = info.split('-').first.squish if info.present?
      js << {"#{table_name} - Code" => t_code}
      [js.reduce({},:merge),t_name]
    end
end

# 

