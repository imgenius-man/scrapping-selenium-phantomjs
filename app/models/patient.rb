class Patient < ActiveRecord::Base
  require 'csv'
  require 'parsers/parse_container'
  require 'parsers/parse_availity'

  extend PatientsHelper

  attr_accessible :record_available, :dob, :first_name, :last_name, :patient_id, :username, :password, :site_to_scrap, :token, :raw_html, :json, :site_url, :practice_name, :payer_name, :provider_type, :place_of_service, :service_type

  serialize :json, JSON

  def self.new_jsn(json_obj)

    json = ParseAvaility.new.parse_panels(json_obj)

  end

  def self.clean(id)
    a=Patient.find(id)
    a.raw_html = nil
    a.json = nil
    a.record_available = "failed"
    a.save
  end

  def self.parse_containers(containers, date_of_eligibility, eligibility_status, transaction_date)
    @cont = ParseContainer.new.tabelizer(containers)

    @json = []

    @cont.each do |cont|
      cont[1..cont.length].each do |con|
       @json << ParseTable.new.json_table(con[:table], cont.first[:name], con[:header_count], con[:additional_info], cont.last[:info])
      end
    end

    @json.reject!(&:nil?).reject!{|a| a == false}
      @json = [{'General' => {'ELIGIBILITY AS OF' => date_of_eligibility, 'ELIGIBILITY STATUS' => eligibility_status, 'TRANSACTION DATE' => transaction_date}}] + @json

    @json
  end


  def self.retrieve_signin_fields(site_url)
    options = Patient.options_for_site

    if site_url == options[0][1]
      fields = {user_field: 'username', pass_field: 'password', submit_button: '#button1', error_string: 'error'}

    elsif site_url == options[1][1]
      fields = {user_field: 'portletInstance_6{actionForm.userId}', pass_field: 'portletInstance_6{actionForm.password}', submit_button: '.button_submit', error_string: 'login'}
    elsif site_url == options[2][1]
      fields = {user_field: 'userId', pass_field: 'password', submit_button: '#loginFormSubmit', error_string: 'public.elegant.login'}
    end

    fields
  end


  def self.import(file)
      CSV.foreach(file.path, headers: true) do |row|
      user_hash = row.to_hash
      str = row.to_s.split(',')

      a= Patient.find_by_patient_id(str[3])
      if a
        a.update_attributes(first_name: str[0],last_name: str[1],dob: str[2],patient_id: str[3])
      else
        a=Patient.new
        a.first_name = str[0].squish if str[0]
        a.last_name = str[1].squish if str[1]
        a.dob = str[2].squish if str[2]
        a.patient_id = str[3].squish if str[3]
        a.save!
      end
    end
  end

  def self.import_mapping(file,id)
    obj = Status.find(id).service_types
    ServiceType.where(status_id: id).destroy_all

    CSV.foreach(file.path, headers: true) do |row|
      user_hash = row.to_hash
      str = row.to_s.split(',')

    if row.to_s.scan(/,/).count > 1
      new_str=[]
      new_str[0]=""
      str[0..str.count-2].each {|d|
        new_str[0] = new_str[0] + d + " "
      }
      new_str[1] = str[str.count-1].strip
      str = new_str
    end

        obj.create(type_name: (str[0].squish if str[0].present?), type_code: (str[1].squish if str[1].present?))

    end
  end

  def self.aetna(driver)
    
    tables = driver.find_elements(:tag_name, 'table')

    member_info = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[2].attribute('innerHTML'),nil,Mechanize.new)

    subscriber_info = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[5].attribute('innerHTML'),nil,Mechanize.new)

    benefit_info = Mechanize::Page.new(nil,{'content-type'=>'text/html'},tables[7].attribute('innerHTML'),nil,Mechanize.new)

    mega_arr = []

    if member_info.search('.clsEmphasized').first.text.squish == "Member Information"
      
      field_labels = member_info.search('.FieldLabel')
      field_data = member_info.search('.FieldData')

        ar = []
        indexes = []
        
        flag = true
        
        field_labels.each_with_index {|fl,index|
        
          if fl.text != " " && fl.text.present? && (flag || fl.text != "Address:")
            flag = false if fl.text == "Address:"
            ar << { fl.text.squish.split(':').first => field_data[index].text.squish }
          
          elsif fl.text== " "
              indexes << index
          
          end
          
        }
        ar = ar.reduce({},:merge)
        ar["Address"] = ar["Address"]+", #{field_data[3].text.squish}"
        # puts "====="*23
        # puts ar
        # puts "+++++"*23
        mega_arr << {"Member Information" => ar}
        # puts mega_arr
        # puts "----"*23

    end
    if subscriber_info.search('.clsEmphasized').first.text.squish == "Subscriber/Group Information"
      
      field_labels = subscriber_info.search('.FieldLabel')
      field_data = subscriber_info.search('.FieldData')
      ar = []
      field_labels.each_with_index {|fl,index|
        if fl.text != " " && fl.text.present?
          ar << { fl.text.squish.split(':').first => field_data[index].text.squish }
        end
      }
      # puts "====="*23
      # puts ar
      # puts "+++++"*23
      ar = ar.reduce({},:merge)
      mega_arr << {"Subscriber Information" => ar }
      # puts mega_arr
      # puts "----"*23
    end
    if benefit_info.search('.clsEmphasized').first.text.squish == "Benefit Description"
      
      field_labels = benefit_info.search('.FieldLabel')
      field_data = benefit_info.search('.FieldData')
      ar = []
      field_labels.each_with_index {|fl,index|
        if fl.text != " " && fl.text.present?
          ar << { fl.text.squish.split(':').first => field_data[index].text.squish }
        end
      }
      # puts "====="*23
      # puts ar
      # puts "+++++"*23
      ar = ar.reduce({},:merge)
      mega_arr << {"Benefit Description" => ar }
      # puts mega_arr
      # puts "----"*23
          
    end
    mega_arr.reduce({},:merge)

  end

end
