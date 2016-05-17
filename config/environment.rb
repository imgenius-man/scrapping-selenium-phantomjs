# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
Academia::Application.initialize!
my_date_formats = { :default => '%m/%d/%Y' } 
Time::DATE_FORMATS.merge!(my_date_formats) 
Date::DATE_FORMATS.merge!(my_date_formats)


CIGNA_USERNAME = "SandyF99"
CIGNA_PASSWORD = "Empclaims100"
MHNET_USERNAME = "ka2002pa"
MHNET_PASSWORD = "Pcc63128"
AVAILITY_USERNAME = "statpay"
AVAILITY_PASSWORD = "Medicare#01"
