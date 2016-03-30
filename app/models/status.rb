class Status < ActiveRecord::Base
  attr_accessible :date_checked, :site_url, :status
  has_many :service_types
end
