class ParseAetna

  def parse_tables_aetna(tables)
    mega_arr = []
    coinsuarance = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[11].attribute('innerHTML'),nil,Mechanize.new)
    tr = coinsuarance.search('tr')

    mega_arr << {"Coinsuarnce"=>aetna_parse_coinsuarnce(tr)}


    copayment = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[15].attribute('innerHTML'),nil,Mechanize.new)
    tr = copayment.search('tr')

    mega_arr << {"Copayment"=>aetna_parse_copayment(tr)}

    deductibles = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[19].attribute('innerHTML'),nil,Mechanize.new)
    tr = deductibles.search('tr')

    mega_arr << {"Deductibles"=>aetna_parse_deductibles(tr)}

    limitations = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[23].attribute('innerHTML'),nil,Mechanize.new)
    tr = limitations.search('tr')

    mega_arr << {"Deductibles"=>aetna_parse_limitiation(tr)}


    out_of_pocket = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[27].attribute('innerHTML'),nil,Mechanize.new)
    tr = out_of_pocket.search('tr')

    mega_arr << {"Out of Pocket"=>aetna_parse_out_of_pocket(tr)}


    mega_arr.reduce({},:merge)
  end


  def aetna_parse_coinsuarnce(tr)
    th = tr[0].search('th')
    pre = ["In Network","Out Network"]
    js = []
    (0..(tr.count/3)-1).each_with_index {|n,ind|

      network_td = []
      network_td = tr[(n*3)+2].search('td')
      network_td.each_with_index {|td,index|
         puts "Coinsuarnce - #{pre[ind]} - #{th[index].text.squish} => #{td.text.squish}"
        js << {"Coinsuarnce - #{pre[ind]} - #{th[index].text.squish}" => td.text.squish} 
      }
    }
    js.reduce({},:merge)
  end

  def aetna_parse_copayment(tr)
    th = tr[0].search('th')
    js = []
    (0..(tr.count/3)-1).each_with_index {|n,ind|
      network_td = []
      network_td = tr[(n*3)+2].search('td')
      network_td.each_with_index {|td,index|
         puts "Copayment - #{th[index].text.squish} => #{td.text.squish}"
        js << {"Copayment - #{th[index].text.squish}" => td.text.squish} 
      }
    }
    js.reduce({},:merge)
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
         puts "Deductibles - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish} => #{td.text.squish}"
        js << {"Deductibles - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish}" => td.text.squish} 
      }
    }
    js.reduce({},:merge)
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
         puts "Out of Pocket - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish} => #{td.text.squish}"
        js << {"Out of Pocket - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish}" => td.text.squish} 
      }
    }
    js.reduce({},:merge)
  end

  def aetna_parse_limitiation(tr)
    th = tr[0].search('th')
    in_out = ["In Network","In Network","Out Network","Out Network"]
    fam_ind = ["Individual","Family","Individual","Family"]
    js = []
    (0..(tr.count/3)-1).each_with_index {|n,ind|
      network_td = []
      network_td = tr[(n*3)+2].search('td')
      network_td.each_with_index {|td,index|
         puts "Out of Pocket - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish} => #{td.text.squish}"
        js << {"Out of Pocket - #{fam_ind[ind]} - #{in_out[ind]} - #{th[index].text.squish}" => td.text.squish} 
      }
    }
    js.reduce({},:merge)
  end

end
