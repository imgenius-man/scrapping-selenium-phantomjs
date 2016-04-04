# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
User.create(email: 'admin@goopher.com', password: 'Skedia&&105', password_confirmation: 'Skedia&&105')

Status.create(site_url: 'all', date_checked: Time.now)
Status.create(site_url: 'https://cignaforhcp.cigna.com/', date_checked: Time.now)
Status.create(site_url: 'https://www.mhnetprovider.com/', date_checked: Time.now)

