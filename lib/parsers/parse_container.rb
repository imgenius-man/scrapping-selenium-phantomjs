class ParseContainer
	require 'parsers/parse_table'


	def parse_all(containers)
		@tables_v  = {}
		@tables_h  = {}
		
		@tables = []
		@cont = []

		containers.each do |container|
		  cont = container.attribute('innerHTML')

		  page = Mechanize::Page.new(nil,{'content-type'=>'text/html'},cont,nil,Mechanize.new)
		  
		  table_text = page.at('div').text.squish
		  
		  cont_info = page.at('div > .info-text').text.squish if page.at('div > .info-text').present?

		  table_info_arr = page.search('div.notes')

		  tables_content = page.search('table')
		  
		  tables_content.each_with_index do |tab, i|
		    @tables_h = tab.search('thead > tr').map do |tr|
		    {
		      tr: tr.search('th').map do |q| 
		      {
		        th: q.children.map do |l| 
		          l.text.squish if l.name == 'text'
		        end
		        .reject(&:nil?)
		      }   
		      end
		    }
		    end

		    @tables_v = tab.search('tbody > tr').map do |tr|
		    {
		      tr: tr.search('td').map do |q| 
		      {
		        td: q.children.map do |l| 
		          if l.children.present?
		            if l.name == 'p' || l.name == 'a'  
		              l.children.text.squish
		            
		            elsif l.name == 'div' && l.attributes["class"].present? && l.attributes["class"].value == "icon-notificationsSmall cigna-careDesignation"
		              l.children.text.squish + " (Special)"

		            elsif l.name == 'ul'
		              " " + l.children.text.squish      
		            end 
		          
		          else
		            l.text.squish if l.name == 'text'
		          end
		        end
		        .reject(&:nil?)
		      }   
		      end
		    }
		    end

		    @tables << [table: @tables_h.flatten + @tables_v.flatten, header_count: @tables_h.count, additional_info: (table_info_arr[i].text.squish if table_info_arr[i].present?) ]
		  end
		  
		  @cont << [name: table_text] + @tables.flatten + [info: cont_info]
		  
		  @tables = []
		end

		@cont
	end
end