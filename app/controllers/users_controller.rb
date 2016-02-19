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
    respond_to do |format|
      format.xls {
    # begin
      if params[:user][:first_name].present? && params[:user][:last_name].present? && params[:user][:dob].present? && params[:user][:patient_id].present?
        wait = Selenium::WebDriver::Wait.new(timeout: 20)
        
        driver = Selenium::WebDriver.for :firefox
        # , :args => ['--ignore-ssl-errors=true']
        
        driver.navigate.to "https://cignaforhcp.cigna.com/web/secure/chcp/windowmanager#tab-hcp.pg.patientsearch$1"
        
        username = driver.find_element(:name, 'username')
        username.send_keys "skedia105"

        password = driver.find_element(:name, 'password')
        password.send_keys "Empclaims100"

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
        # wait.until {
        #    driver.find_elements(:class,'patient-results-onDate').displayed?
        #   }
        eee = driver.find_elements(:class,'btn-submit-form-patient-search')[0]
        if !eee.present?
          link = nil
          wait.until {
            link = driver.find_elements(:class,'oep-managed-link')[5]
          }
          link.click

          wait.until { driver.find_elements(:class, 'collapseTable').present? }

          tables = driver.find_elements(:class, 'collapseTable')

          sanit = ActionView::Base


          # .to_html
          # page.search('tbody > tr')[0].search('td')[0].children.map{|l| l.text.squish if l.name == 'text'}.reject(&:nil?)
          # str.slice(0..str.index(/\n/)-1)



          @tables = []
          @tables_v = []
          @tables_h = []

          tables.each do |table|
            tab = table.attribute('innerHTML')

            page = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tab,nil,Mechanize.new)
          
            @tables_h = page.search('thead > tr:last').map do |tr|
            [
              tr: tr.search('th').map do |q| 
              [
                th: q.children.map do |l| 
                  l.text.squish if l.name == 'text'
                end
                .reject(&:nil?)
              ]   
              end
            ]
            end

            @tables_v = page.search('tbody > tr').map do |tr|
            [
              tr: tr.search('td').map do |q| 
              [
                td: q.children.map do |l| 
                  l.text.squish if l.name == 'text'
                end
                .reject(&:nil?)
              ]   
              end
            ]
            end

            @tables << @tables_h.flatten + @tables_v.flatten 
          end
        
          puts "==="*100
          puts @tables[0]

          driver.quit
        
        else
          flash[:danger] = "Please enter correct information"
        
          redirect_to :back
        end
      
      else
        flash[:danger] = "All fields are required."
        
        redirect_to :back
      end

     render text: User.to_csv({col_sep: "\t"},@tables) }
    end
    
    # rescue Exception=> e
    #   puts "77777"*90
    #   puts e.inspect
      
    #   flash[:info] = "Time Out. Please try again later."
      
    #   redirect_to :back
    # end 
  end
end
