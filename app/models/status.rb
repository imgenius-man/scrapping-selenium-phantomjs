class Status < ActiveRecord::Base
  attr_accessible :date_checked, :site_url, :status, :site_username, :site_password
  has_many :service_types
end
