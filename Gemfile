source 'https://rubygems.org'
ruby '2.1.2'
gem 'daemons'
gem 'rails', '3.2.14'
gem 'selenium-webdriver'
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

curl --data 'user[first_name]=PARUL&user[last_name]=PATEL&user[dob]=15/06/1986&user[patient_id]=U5151043002&user[username]=skedia105&user[password]=Empclaims100&user[site_url]=https://cignaforhcp.cigna.com/web/secure/chcp/windowmanager#tab-hcp.pg.patientsearch$1]' http://gooper-dashboard.statpaymd.com/users/access_token