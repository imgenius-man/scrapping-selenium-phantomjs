class TestCaseStatus < ActiveRecord::Base
  attr_accessible :site_id, :status_name, :status_result
  belongs_to :status

end
