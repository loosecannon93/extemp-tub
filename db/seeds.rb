# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
Site.create :name => "MSNBC", :url => "http://msnbc.com"
Site.create :name => "NPR", :url => "http://npr.org"
Site.create :name => "REUTERS", :url => "http://reuters.com"
Site.create :name => "GUARDIAN", :url => "http://guardian.co.uk"
