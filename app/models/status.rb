class Status < ActiveRecord::Base
  # attr_accessor :date_checked, :site_url, :status, :site_username, :site_password
  serialize :test_status_hash, Hash

  has_many :service_types
  has_many :test_case_statuses

  def self.false_all(status_site)
    status_site.test_status_hash.each { |key,value|
      status_site.test_status_hash[key] = "false"
    }
    status_site.save!
  end
end
