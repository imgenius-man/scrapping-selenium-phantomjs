source 'https://rubygems.org'
ruby '2.1.2'
gem 'daemons'
gem 'rails', '3.2.14'
gem 'selenium-webdriver'
gem 'whenever'
gem 'test-unit'
gem 'headless'
gem "rack-timeout"
gem 'mechanize'
gem 'delayed_job_active_record'
gem 'watir-webdriver'
gem 'rest-client'
gem 'sanitize'
# gem 'wait_until'
gem 'heroku'
gem 'american_date'
# gem 'bootstrap-datepicker-rails'
gem 'bootstrap-datepicker-rails', :require => 'bootstrap-datepicker-rails',:git => 'git://github.com/Nerian/bootstrap-datepicker-rails.git'
# gem 'bootstrap-datetimepicker-rails'
gem 'pg'
gem 'will_paginate', '~> 3.0.5'
group :production do
   gem 'pg'
end

group :development, :test do
  gem 'sqlite3'
  gem 'mysql2', '~> 0.3.10'
end

gem 'activerecord-import'

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier', '>= 1.0.3'
  gem 'therubyracer'
  gem 'execjs'
end

gem "iconv"
gem 'roo'
gem 'roo-xls'
gem 'jquery-rails', '~> 2.2.1'
gem 'bootstrap-sass', '~> 2.3.2.2'
gem 'twitter-bootstrap-rails'
gem 'cancan'
# gem 'devise'
gem 'figaro'
gem 'rolify'
gem 'simple_form'
gem 'activeadmin'
gem 'jquery-datatables-rails', github: 'rweng/jquery-datatables-rails'
gem 'carrierwave'
gem 'carrierwave-dropbox'
# gem 'mailchimp'
# gem "mandrill-api", "~> 1.0.42"
# gem 'mandrill_mailer'





group :development do
  gem 'better_errors'
  gem 'quiet_assets'
  gem 'binding_of_caller'
end
group :development, :test do
  gem 'factory_girl_rails'
  gem 'rspec-rails'
end
group :test do
  gem 'capybara'
  gem 'cucumber-rails', :require=>false
  gem 'database_cleaner', '1.0.1'
  gem 'email_spec'
  #gem 'launchy'
end

# {
# "Plan Level Coinsurance, Deductibles and Maximums": {
# "Family Deductible Amount - In-Network": "$3,000.00",
# "Family Deductible Met - In-Network": "$4.04",
# "Family Deductible Remaining - In-Network": "$2,995.96",
# "Family Deductible Amount - Out-of-Network": "$6,000.00",
# "Family Deductible Met - Out-of-Network": "$0.00",
# "Family Deductible Remaining - Out-of-Network": "$6,000.00",
# "Family Out-of-Pocket Maximum Amount - In-Network": "$6,000.00",
# "Family Out-of-Pocket Maximum Met - In-Network": "$4.04",
# "Family Out-of-Pocket Maximum Remaining - In-Network": "$5,995.96",
# "Family Out-of-Pocket Maximum Amount - Out-of-Network": "$24,000.00",
# "Family Out-of-Pocket Maximum Met - Out-of-Network": "$0.00",
# "Family Out-of-Pocket Maximum Remaining - Out-of-Network": "$24,000.00",
# "Coinsurance Amount - In-Network": "20%",
# "Coinsurance Met - In-Network": "--",
# "Coinsurance Remaining - In-Network": "--",
# "Coinsurance Amount - Out-of-Network": "40%",
# "Coinsurance Met - Out-of-Network": "--",
# "Coinsurance Remaining - Out-of-Network": "--",
# "Lifetime Maximum Amount - In-Network": "Unlimited",
# "Lifetime Maximum Met - In-Network": "Not Applicable",
# "Lifetime Maximum Remaining - In-Network": "Unlimited",
# "Lifetime Maximum Amount - Out-of-Network": "Does Not Apply",
# "Lifetime Maximum Met - Out-of-Network": "--",
# "Lifetime Maximum Remaining - Out-of-Network": "--",
# "Additional Notes": "In-Network and Out-of-Network Deductible and Out-of-Pocket expenses include Medical, Mental Health and Pharmacy. -- Utilization Data is not available for this benefit."
# }}

# # dummy array
# temp = dummy_array.map{|k,v| {k.upcase.gsub(/[-\s+]/, '') => ''}}.reduce({},:merge)

# # data array
# data_array.each{|k,v| temp[k.upcase.gsub(/[-\s+]/,'')] = v }

# # final
# dummy_array.each{ |k,v| a[k] = temp[k.upcase.gsub(/[-\s+]/,'')]}