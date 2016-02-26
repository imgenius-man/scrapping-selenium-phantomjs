class UsersController < ApplicationController

	
  def access_token
    if params[:user].present? && params[:user][:first_name].present? && params[:user][:last_name].present? && params[:user][:dob].present? && params[:user][:patient_id].present?
      token = SecureRandom.base64(24)
      
      created = User.create(params[:user], token: token)
      
      if created
        result = params[:user].merge({token: token})

        Delayed::Job.enqueue Crawler.new(result[:first_name], result[:last_name], result[:dob], result[:patient_id])
      end
    
    else
      result = 'Not permitted'
    end
    
    render json: result
  end
  

  def search_data
    begin
      if params[:user][:first_name].present? && params[:user][:last_name].present? && params[:user][:dob].present? && params[:user][:patient_id].present? && params[:user][:password].present? && params[:user][:username].present?        
        wait = Selenium::WebDriver::Wait.new(timeout: 20)
        
        driver = Selenium::WebDriver.for :phantomjs, :args => ['--ignore-ssl-errors=true']
        # collapseTable-container
        driver.navigate.to "https://cignaforhcp.cigna.com/web/secure/chcp/windowmanager#tab-hcp.pg.patientsearch$1"
        
        username = driver.find_element(:name, 'username')
        username.send_keys params[:user][:username]

        password = driver.find_element(:name, 'password')
        password.send_keys params[:user][:password]

        element = driver.find_element(:id, 'button1')
        element.submit
        
        href_search = ''
        wait.until { 
          href_search = driver.find_elements(:class,'patients')[1]
        }
        href_search.click
       
        member_id = nil
        wait.until {  
          member_id = driver.find_element(:name, 'memberDataList[0].memberId')
        }

        member_id.send_keys params[:user][:patient_id]

        dob = driver.find_element(:name, 'memberDataList[0].dobDate')
        dob.send_keys params[:user][:dob]
        
        first_name = driver.find_element(:name, 'memberDataList[0].firstName')
        first_name.send_keys params[:user][:last_name]
        
        last_name = driver.find_element(:name, 'memberDataList[0].lastName')
        last_name.send_keys params[:user][:first_name]
        
        ee = driver.find_elements(:class,'btn-submit-form-patient-search')[0]
        ee.submit

        sleep(2)
        eee = driver.find_elements(:class,'btn-submit-form-patient-search')[0]
        if !eee.present?
          link = nil
          wait.until {
            link = driver.find_elements(:css,'.patient-search-result-table > tbody > tr > td > .oep-managed-link')[0]
          }
          link.click

          wait.until { driver.find_elements(:class, 'collapseTable').present? }

          if driver.find_elements( :class,"oep-managed-sub-tab").second.displayed?
            driver.find_elements( :class,"oep-managed-sub-tab").second.click
          end

          sleep(4)

          wait.until { driver.find_elements(:class, 'collapseTable').present? }
 
          containers = driver.find_elements(:class, 'collapseTable-container')

          sanit = ActionView::Base

         @tables_v  = {}
         @tables_h  = {}
         @tables = []

         @cont = []

         containers.each do |container|
            cont = container.attribute('innerHTML')

            page = Mechanize::Page.new(nil,{'content-type'=>'text/html'},cont,nil,Mechanize.new)
            
            table_text = page.at('div').text.squish
            
            table_info = page.at('div > .info-text').text.squish if page.at('div > .info-text').present?

            tables_content = page.search('table')
            
            tables_content.each do |tab|
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
                        l.children.text.squish + " (C)"

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

              @tables << [ table: @tables_h.flatten + @tables_v.flatten, header_count: @tables_h.count]
            end
            
            @cont << [name: table_text] + @tables.flatten + [info: table_info]
            
            # @cont << cont
            @tables = []
          end
        
          driver.quit
          
          @json = []

          @cont.each do |cont|
            cont[1..cont.length].each do |con| 
             @json << User.json_table(con[:table], cont.first[:name], con[:header_count], cont.last[:info])
            end
          end
          
          @json.reject!(&:nil?).reject!{|a| a == false}

        else
          flash[:danger] = "Please enter correct information"
        
          redirect_to :back
        end
      
      else
        flash[:danger] = "All fields are required."
        
        redirect_to :back
      end
    
    rescue Exception=> e
      puts "77777"*90
      puts e.inspect
      
      flash[:info] = "Time Out. Please try again later."
      
      redirect_to :back
    end 
  end


  
end
