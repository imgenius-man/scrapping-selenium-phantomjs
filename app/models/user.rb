class User < ActiveRecord::Base
  attr_accessible :dob, :first_name, :last_name, :patient_id
end
